import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitness_timer_app/core/di/injection.dart';
import 'package:fitness_timer_app/core/notifications/timer_notification_service.dart';
// import 'package:fitness_timer_app/core/services/health_sync_service.dart'; // TODO: health plugin disabled
import 'package:fitness_timer_app/core/services/haptic_service.dart';
import 'package:fitness_timer_app/core/services/recovery_hint_service.dart';
import 'package:fitness_timer_app/core/services/timer_background_service.dart';
import 'package:fitness_timer_app/core/utils/time_format.dart';
import 'package:fitness_timer_app/data/models/timer_snapshot.dart';
import 'package:fitness_timer_app/data/models/workout_history.dart';
import 'package:fitness_timer_app/data/timer_snapshot_repository.dart';
import 'package:fitness_timer_app/data/workout_history_repository.dart';
import 'package:fitness_timer_app/domain/timer/interval_engine.dart';
import 'package:fitness_timer_app/models/workout_config.dart';

/// Simple timer snapshot validity: recoverable within 5 minutes.
const _snapshotMaxAge = Duration(minutes: 5);

/// Riverpod simple timer controller (mirrors TimerProvider behaviour).
class SimpleTimerController extends StateNotifier<TimerState> {
  SimpleTimerController(WorkoutConfig config)
      : _sourceId = _configHash(config),
        _engine = getIt<IntervalEngineFactory>()(
          getIt<WorkoutConfigIntervalBuilderFactory>()(config).build(),
        ),
        _notificationService = getIt<TimerNotificationService>(),
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
    _runRecovery();
  }

  static String _configHash(WorkoutConfig config) =>
      '${config.warmupSeconds}_${config.workSeconds}_${config.restSeconds}_${config.rounds}';

  final String _sourceId;
  final IntervalEngine _engine;
  final TimerNotificationService _notificationService;
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

  Future<void> _runRecovery() async {
    final snap = await _snapshotRepo.getLatestWithin(
      TimerSnapshotKind.simple.name,
      _sourceId,
      _snapshotMaxAge,
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
    await _snapshotRepo.clear(TimerSnapshotKind.simple.name, _sourceId);
    state = _engine.state;
    _recoveryHint.notifyRecovered();
    if (snap.status == TimerStatus.running.index) {
      _ensureTicker();
      _scheduleCurrentIntervalNotification();
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
    _scheduleCurrentIntervalNotification();
  }

  void pause() {
    _haptic.trigger(HapticType.medium);
    _engine.pause();
    _notificationService.cancelAll();
    _backgroundService.stopService();
    state = _engine.state;
  }

  void resume() {
    _haptic.trigger(HapticType.medium);
    _engine.resume();
    _ensureTicker();
    state = _engine.state;
    _scheduleCurrentIntervalNotification();
  }

  void reset() {
    _haptic.trigger(HapticType.medium);
    _engine.reset();
    _stopTicker();
    _notificationService.cancelAll();
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
    _scheduleCurrentIntervalNotification();
  }

  void _ensureTicker() {
    _ticker ??= Timer.periodic(const Duration(milliseconds: 200), (_) {
      final previousIndex = state.currentIntervalIndex;
      _engine.tick();
      state = _engine.state;

      if (state.isFinished) {
        _haptic.trigger(HapticType.heavy);
        _stopTicker();
        _notificationService.cancelAll();
        _backgroundService.stopService();
        _saveHistoryIfFinished();
        return;
      }

      // Update foreground notification countdown (MM:SS) every second
      if (state.status == TimerStatus.running &&
          state.elapsed.inSeconds != _lastNotifiedSecond) {
        _lastNotifiedSecond = state.elapsed.inSeconds;
        _backgroundService.updateNotification(
          'Fitness Timer',
          formatMMSS(state.remaining.inSeconds),
        );
      }

      if (state.currentIntervalIndex != previousIndex &&
          state.status == TimerStatus.running) {
        _haptic.trigger(HapticType.success);
        _scheduleCurrentIntervalNotification();
      }

      final remaining = _currentIntervalRemainingSeconds();
      if (remaining <= 3 &&
          remaining >= 1 &&
          _lastAnnouncedSecond != remaining) {
        _lastAnnouncedSecond = remaining;
        _haptic.trigger(HapticType.selection);
      }

      // Throttled persistence: write snapshot only when elapsed seconds change and status is running/paused
      if ((state.status == TimerStatus.running ||
              state.status == TimerStatus.paused) &&
          _startedAtWall != null &&
          state.elapsed.inSeconds != _lastPersistedSecond) {
        _lastPersistedSecond = state.elapsed.inSeconds;
        _persistSnapshot();
      }
    });
  }

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

  void _persistSnapshot() {
    if (_startedAtWall == null) return;
    final s = TimerSnapshot.fromValues(
      kind: TimerSnapshotKind.simple.name,
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

  void _scheduleCurrentIntervalNotification() {
    if (state.status != TimerStatus.running || state.intervals.isEmpty) {
      return;
    }

    final intervals = state.intervals;
    final index = state.currentIntervalIndex.clamp(0, intervals.length - 1);

    // Remaining time in current interval: intervalRemaining = interval.duration - intervalElapsed
    final elapsed = state.elapsed;
    var acc = Duration.zero;
    for (var i = 0; i < index; i++) {
      acc += intervals[i].duration;
    }
    final currentDuration = intervals[index].duration;
    final intervalElapsed = elapsed - acc;
    final intervalRemaining = currentDuration - intervalElapsed;

    if (intervalRemaining <= Duration.zero) return;

    final when = DateTime.now().add(intervalRemaining);

    _notificationService
        .cancelAll()
        .then(
          (_) => _notificationService.schedulePhaseEnd(
            when: when,
            title: 'Fitness Timer',
            body: intervals[index].label ?? 'Interval finished',
          ),
        );
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _saveHistoryIfFinished() {
    if (!state.isFinished || _startedAtWall == null) return;
    final totalSec = state.total.inSeconds;
    final calories = (state.total.inMinutes * 7.5).round();
    final record = WorkoutHistory.fromValues(
      planId: _sourceId,
      planTitle: 'Simple Timer',
      startTime: _startedAtWall!,
      totalDurationSeconds: totalSec,
      calories: calories,
      completionRate: state.intervals.isEmpty ? 0.0 : 1.0,
    );
    _historyRepo.save(record);
    // Async sync to health (Health Connect / HealthKit) — disabled when health plugin off
    // _healthSync.uploadWorkout(
    //   duration: state.total,
    //   calories: calories,
    //   workoutTitle: 'Simple Timer',
    //   startTime: _startedAtWall,
    // );
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}

/// Family provider for simpleTimerController: one instance per WorkoutConfig.
final simpleTimerControllerProvider =
    StateNotifierProvider.autoDispose.family<SimpleTimerController, TimerState, WorkoutConfig>(
  (ref, config) => SimpleTimerController(config),
);

