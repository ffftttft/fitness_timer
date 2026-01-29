import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitness_timer_app/core/di/injection.dart';
import 'package:fitness_timer_app/core/audio/tts_service.dart';
// import 'package:fitness_timer_app/core/services/health_sync_service.dart'; // TODO: health plugin disabled
import 'package:fitness_timer_app/core/services/haptic_service.dart';
import 'package:fitness_timer_app/core/services/recovery_hint_service.dart';
import 'package:fitness_timer_app/core/services/timer_background_service.dart';
import 'package:fitness_timer_app/core/utils/time_format.dart';
import 'package:fitness_timer_app/audio/tone_player.dart';
import 'package:fitness_timer_app/core/localization/app_language.dart';
import 'package:fitness_timer_app/data/models/timer_snapshot.dart';
import 'package:fitness_timer_app/data/models/workout_history.dart';
import 'package:fitness_timer_app/data/timer_snapshot_repository.dart';
import 'package:fitness_timer_app/data/workout_history_repository.dart';
import 'package:fitness_timer_app/domain/timer/interval_engine.dart';
import 'package:fitness_timer_app/models/workout_model.dart';

/// Plan workout snapshot validity: recoverable within 5 minutes.
const _planSnapshotMaxAge = Duration(minutes: 5);

/// Args for plan workout controller: plan + language.
///
/// Must implement [==] and [hashCode] so Riverpod family does not treat each rebuild as a new key
/// (which would create a new PlanWorkoutController and break UI timing).
class PlanWorkoutArgs {
  const PlanWorkoutArgs({
    required this.plan,
    required this.language,
  });

  final WorkoutPlan plan;
  final AppLanguage language;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlanWorkoutArgs &&
          plan.id == other.plan.id &&
          language == other.language;

  @override
  int get hashCode => Object.hash(plan.id, language);
}

/// Riverpod plan workout controller; owns timing (PlanWorkoutProvider role).
///
/// - Uses IntervalEngine for time;
/// - TTS and sound logic live here; view only consumes state.
class PlanWorkoutController extends StateNotifier<TimerState> {
  PlanWorkoutController(this._plan, this._language)
      : _sourceId = _plan.id,
        _engine = getIt<IntervalEngineFactory>()(
          getIt<PlanIntervalBuilderFactory>()(_plan).build(),
        ),
        _tts = getIt<TtsService>(),
        _tone = getIt<TonePlayer>(),
        _snapshotRepo = getIt<TimerSnapshotRepository>(),
        _historyRepo = getIt<WorkoutHistoryRepository>(),
        _haptic = getIt<HapticService>(),
        _backgroundService = getIt<TimerBackgroundService>(),
        // _healthSync = getIt<HealthSyncService>(), // TODO: health plugin disabled
        _recoveryHint = getIt<RecoveryHintService>(),
        super(
          const TimerState(
            status: TimerStatus.ready,
            total: Duration.zero,
            elapsed: Duration.zero,
            remaining: Duration.zero,
            currentIntervalIndex: 0,
            intervals: [],
          ),
        ) {
    state = _engine.state;
    // ignore: discarded_futures
    _tts.configure(_language);
    _runRecovery();
  }

  final WorkoutPlan _plan;
  final AppLanguage _language;
  final String _sourceId;
  final IntervalEngine _engine;
  final TtsService _tts;
  final TonePlayer _tone;
  final TimerSnapshotRepository _snapshotRepo;
  final WorkoutHistoryRepository _historyRepo;
  final HapticService _haptic;
  final TimerBackgroundService _backgroundService;
  // final HealthSyncService _healthSync; // TODO: health plugin disabled
  final RecoveryHintService _recoveryHint;
  Timer? _ticker;
  int? _lastAnnouncedSecond;
  int? _lastPersistedSecond;
  int? _lastNotifiedSecond;
  DateTime? _startedAtWall;

  WorkoutPlan get plan => _plan;

  Future<void> _runRecovery() async {
    final snap = await _snapshotRepo.getLatestWithin(
      TimerSnapshotKind.plan.name,
      _sourceId,
      _planSnapshotMaxAge,
    );
    if (snap == null) return;
    if (snap.status != TimerStatus.running.index &&
        snap.status != TimerStatus.paused.index) {
      return;
    }
    final recoveredElapsed = snap.status == TimerStatus.running.index
        ? (DateTime.now().difference(snap.lastUpdatedAtWall) +
            snap.elapsedAtLastUpdate)
        : snap.elapsedAtLastUpdate;
    _engine.restoreFromSnapshot(
      recoveredElapsed: recoveredElapsed,
      pausedAccumulated: snap.pausedAccumulated,
      wasPaused: snap.status == TimerStatus.paused.index,
    );
    _startedAtWall = snap.startedAtWall;
    await _snapshotRepo.clear(TimerSnapshotKind.plan.name, _sourceId);
    state = _engine.state;
    _recoveryHint.notifyRecovered();
    if (snap.status == TimerStatus.running.index) {
      _ensureTicker();
    }
  }

  void start() {
    _haptic.trigger(HapticType.medium);
    _engine.start();
    _startedAtWall = DateTime.now();
    _lastNotifiedSecond = null;
    _backgroundService.startService();
    _ensureTicker();
    state = _engine.state;
    // ignore: discarded_futures
    _tts.speakGetReady();
    _onIntervalStart(isFirstStart: true);
    // If first interval is work, announce "Start <step name>"
    final first = state.intervals.isEmpty ? null : state.intervals.first;
    final firstName = first?.type == IntervalType.work ? first?.label : null;
    if (firstName != null && firstName.trim().isNotEmpty) {
      // ignore: discarded_futures
      Future.delayed(const Duration(milliseconds: 1200), () {
        // ignore: discarded_futures
        _tts.speakStartStep(firstName);
      });
    }
  }

  void pause() {
    _haptic.trigger(HapticType.medium);
    _engine.pause();
    _backgroundService.stopService();
    state = _engine.state;
  }

  void resume() {
    _haptic.trigger(HapticType.medium);
    _engine.resume();
    _ensureTicker();
    state = _engine.state;
  }

  void reset() {
    _haptic.trigger(HapticType.medium);
    _engine.reset();
    _stopTicker();
    _backgroundService.stopService();
    _lastAnnouncedSecond = null;
    _lastPersistedSecond = null;
    _lastNotifiedSecond = null;
    _startedAtWall = null;
    state = _engine.state;
  }

  void skip() {
    _haptic.trigger(HapticType.medium);
    _engine.skipCurrentInterval();
    state = _engine.state;
    _onIntervalStart();
  }

  /// Manually end workout; user chooses whether to save.
  /// Returns true = save, false = do not save, null = cancel.
  Future<bool?> finishWithChoice(Future<bool?> Function() askSaveChoice) async {
    if (state.isFinished || _startedAtWall == null) return null;
    
    pause();
    
    final shouldSave = await askSaveChoice();
    
    if (shouldSave == null) {
      resume();
      return null;
    }
    
    _haptic.trigger(HapticType.heavy);
    _stopTicker();
    _backgroundService.stopService();
    
    if (shouldSave) {
      final completedIntervals = state.currentIntervalIndex;
      final totalIntervals = state.intervals.length;
      final completionRate = totalIntervals > 0 ? completedIntervals / totalIntervals : 0.0;
      
      final workDur = workElapsedWithin(state.intervals, state.elapsed);
      final calories = (workDur.inSeconds * 7.5 / 60).round();
      final record = WorkoutHistory.fromValues(
        planId: _sourceId,
        planTitle: _plan.title.isEmpty ? 'Workout' : _plan.title,
        startTime: _startedAtWall!,
        totalDurationSeconds: state.elapsed.inSeconds,
        calories: calories,
        completionRate: completionRate.clamp(0.0, 1.0),
      );
      _historyRepo.save(record);
    }
    
    await _snapshotRepo.clear(TimerSnapshotKind.plan.name, _sourceId);
    
    // ignore: discarded_futures
    _tone.play(AppTone.tripleBeep);
    
    reset();
    
    return shouldSave;
  }

  void _ensureTicker() {
    _ticker ??= Timer.periodic(const Duration(milliseconds: 200), (_) {
      final previousIndex = state.currentIntervalIndex;
      _engine.tick();
      state = _engine.state;
      assert(() {
        if (state.status == TimerStatus.running &&
            state.elapsed.inSeconds != _lastNotifiedSecond) {
          debugPrint('PlanWorkout tick: ${state.elapsed.inSeconds}s');
        }
        return true;
      }());

      if (state.isFinished) {
        _haptic.trigger(HapticType.heavy);
        _stopTicker();
        _backgroundService.stopService();
        _saveHistoryIfFinished();
        // ignore: discarded_futures
        _tone.play(AppTone.tripleBeep);
        // ignore: discarded_futures
        _tts.speakWorkoutFinishedSaved();
        return;
      }

      // Update foreground notification countdown every second (MM:SS)
      if (state.status == TimerStatus.running &&
          state.elapsed.inSeconds != _lastNotifiedSecond) {
        _lastNotifiedSecond = state.elapsed.inSeconds;
        _backgroundService.updateNotification(
          _plan.title,
          formatMMSS(_currentIntervalRemainingSeconds()),
        );
      }

      if (state.currentIntervalIndex != previousIndex) {
        _haptic.trigger(HapticType.success);
        _onIntervalStart();
      }

      final remaining = _currentIntervalRemainingSeconds();
      if (remaining <= 3 &&
          remaining >= 1 &&
          _lastAnnouncedSecond != remaining) {
        _lastAnnouncedSecond = remaining;
        _haptic.trigger(HapticType.selection);
        // ignore: discarded_futures
        _tone.play(AppTone.pop);
        // ignore: discarded_futures
        _tts.speakCountdown(remaining);
      }

      // Throttled persistence every second
      if ((state.status == TimerStatus.running ||
              state.status == TimerStatus.paused) &&
          _startedAtWall != null &&
          state.elapsed.inSeconds != _lastPersistedSecond) {
        _lastPersistedSecond = state.elapsed.inSeconds;
        _persistSnapshot();
      }
    });
  }

  void _persistSnapshot() {
    if (_startedAtWall == null) return;
    final s = TimerSnapshot.fromValues(
      kind: TimerSnapshotKind.plan.name,
      sourceId: _sourceId,
      status: state.status.index,
      startedAtWall: _startedAtWall!,
      lastUpdatedAtWall: DateTime.now(),
      elapsedAtLastUpdate: state.elapsed,
      pausedAccumulated: _engine.pausedAccumulated,
      currentIntervalIndex: state.currentIntervalIndex,
    );
    _snapshotRepo.save(s);
  }

  /// Remaining seconds in current interval (for countdown and phase-end logic).
  int _currentIntervalRemainingSeconds() {
    if (state.intervals.isEmpty || state.isFinished) return 0;
    final intervals = state.intervals;
    final index = state.currentIntervalIndex.clamp(0, intervals.length - 1);
    final elapsed = state.elapsed;
    var acc = Duration.zero;
    for (var i = 0; i < index; i++) {
      acc += intervals[i].duration;
    }
    final current = intervals[index].duration;
    final intervalElapsed = elapsed - acc;
    final intervalRemaining = current - intervalElapsed;
    return intervalRemaining.inSeconds.clamp(0, 1 << 30);
  }

  String? _previousWorkLabel(List<Interval> intervals, int fromIndex) {
    for (var i = fromIndex - 1; i >= 0; i--) {
      final it = intervals[i];
      if (it.type == IntervalType.work) return it.label;
    }
    return null;
  }

  String? _nextWorkLabel(List<Interval> intervals, int fromIndex) {
    for (var i = fromIndex + 1; i < intervals.length; i++) {
      final it = intervals[i];
      if (it.type == IntervalType.work) return it.label;
    }
    return null;
  }

  void _onIntervalStart({bool isFirstStart = false}) {
    _lastAnnouncedSecond = null;
    if (state.intervals.isEmpty || state.isFinished) return;
    final intervals = state.intervals;
    final index = state.currentIntervalIndex.clamp(0, intervals.length - 1);
    final interval = intervals[index];

    // TTS: strict EN/ZH separation; only user step names are concatenated
    if (!isFirstStart) {
      switch (interval.type) {
        case IntervalType.warmup:
          break;
        case IntervalType.rest:
          final prevWork = _previousWorkLabel(intervals, index);
          final nextWork = _nextWorkLabel(intervals, index);
          final isStepSwitchRest =
              prevWork != null && nextWork != null && prevWork != nextWork;
          if (isStepSwitchRest) {
            // ignore: discarded_futures
            _tts.speakStepFinishedThenRest(prevWork);
          } else {
            // ignore: discarded_futures
            _tts.speakRest();
          }
          break;
        case IntervalType.work:
          final stepName = interval.label;
          if (stepName == null || stepName.trim().isEmpty) {
            break;
          }
          final cameFromRest =
              index > 0 && intervals[index - 1].type == IntervalType.rest;
          if (cameFromRest) {
            final prevWork = _previousWorkLabel(intervals, index);
            final isContinue = prevWork != null && prevWork == stepName;
            // ignore: discarded_futures
            _tts.speakRestOverThenStep(stepName, isContinue: isContinue);
          } else {
            // ignore: discarded_futures
            _tts.speakStartStep(stepName);
          }
          break;
        case IntervalType.cooldown:
          break;
      }
    }
  
    switch (interval.type) {
      case IntervalType.work:
        // ignore: discarded_futures
        _tone.play(AppTone.doubleBeep);
        break;
      case IntervalType.warmup:
      case IntervalType.rest:
      case IntervalType.cooldown:
        // ignore: discarded_futures
        _tone.play(AppTone.soft);
        break;
    }
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _saveHistoryIfFinished() {
    if (!state.isFinished || _startedAtWall == null) return;
    final workDur = workElapsedWithin(state.intervals, state.elapsed);
    final calories = (workDur.inSeconds * 7.5 / 60).round();
    final record = WorkoutHistory.fromValues(
      planId: _sourceId,
      planTitle: _plan.title.isEmpty ? 'Workout' : _plan.title,
      startTime: _startedAtWall!,
      totalDurationSeconds: state.total.inSeconds,
      calories: calories,
      completionRate: state.intervals.isEmpty ? 0.0 : 1.0,
    );
    _historyRepo.save(record);
    // TODO: health plugin disabled (Health Connect / HealthKit sync)
    // _healthSync.uploadWorkout(
    //   duration: state.total,
    //   calories: calories,
    //   workoutTitle: _plan.title.isEmpty ? 'Workout' : _plan.title,
    //   startTime: _startedAtWall,
    // );
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}

/// Provides a PlanWorkoutController for a given WorkoutPlan.
///
/// In WorkoutView: ref.watch(planWorkoutControllerProvider(args))
/// to get state similar to TimerPage.
final planWorkoutControllerProvider =
    StateNotifierProvider.autoDispose.family<PlanWorkoutController, TimerState, PlanWorkoutArgs>(
  (ref, args) => PlanWorkoutController(args.plan, args.language),
);

