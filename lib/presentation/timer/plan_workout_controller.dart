import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitness_timer_app/core/di/injection.dart';
import 'package:fitness_timer_app/core/audio/tts_service.dart';
// import 'package:fitness_timer_app/core/services/health_sync_service.dart'; // TODO: 暂时禁用 health 插件
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

/// 计划训练快照效期：5 分钟内可恢复
const _planSnapshotMaxAge = Duration(minutes: 5);

/// 计划训练控制器输入参数：计划本身 + 语言环境。
///
/// 必须实现 [==] 与 [hashCode]，否则 Riverpod family 每次 rebuild 会当作新 key，
/// 创建新的 PlanWorkoutController，导致「点击运行有播报但界面不计时」。
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

/// Riverpod 版计划训练控制器，对应当前 PlanWorkoutProvider 的计时职责。
///
/// - 使用 IntervalEngine 驱动时间；
/// - 将 TTS 播报和提示音逻辑下沉到控制器内部，View 只关心状态。
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
        // _healthSync = getIt<HealthSyncService>(), // TODO: 暂时禁用 health 插件
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
  // final HealthSyncService _healthSync; // TODO: 暂时禁用 health 插件
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
    // 开始时播报：准备开始
    // ignore: discarded_futures
    _tts.speakGetReady();
    _onIntervalStart(isFirstStart: true);
    // 如果没有 warm-up，首段就是步骤：补一句“开始<步骤名>”
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

  /// 手动结束训练，让用户选择是否保存记录。
  /// 返回 true 表示用户选择保存，true 表示不保存，null 表示取消。
  Future<bool?> finishWithChoice(Future<bool?> Function() askSaveChoice) async {
    if (state.isFinished || _startedAtWall == null) return null;
    
    // 暂停计时器，防止误触
    pause();
    
    // 让用户选择是否保存
    final shouldSave = await askSaveChoice();
    
    if (shouldSave == null) {
      // 用户取消，恢复训练
      resume();
      return null;
    }
    
    _haptic.trigger(HapticType.heavy);
    _stopTicker();
    _backgroundService.stopService();
    
    if (shouldSave) {
      // 计算实际完成率：已经完成的 interval 数 / 总 interval 数
      final completedIntervals = state.currentIntervalIndex;
      final totalIntervals = state.intervals.length;
      final completionRate = totalIntervals > 0 ? completedIntervals / totalIntervals : 0.0;
      
      // 保存历史记录
      final calories = (state.elapsed.inMinutes * 7.5).round();
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
    
    // 清除快照，避免重新进入时恢复
    await _snapshotRepo.clear(TimerSnapshotKind.plan.name, _sourceId);
    
    // 播放结束音
    // ignore: discarded_futures
    _tone.play(AppTone.tripleBeep);
    
    // 重置状态
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
        // 训练完成：提示已保存 + 鼓励
        // ignore: discarded_futures
        _tts.speakWorkoutFinishedSaved();
        return;
      }

      // 每秒更新前台通知栏倒计时（MM:SS）
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

      // 秒级节流持久化
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

  /// 当前 interval 内剩余秒数（用于倒计时与阶段结束逻辑）。
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

    // 语音播报逻辑（中文/英文严格分离；仅拼接用户步骤名）
    // 目标（示例）：准备开始训练 -> 开始步骤一 -> 休息一下 -> 休息结束继续步骤一 -> 步骤一结束休息一下 -> 休息结束开始步骤二...
    if (!isFirstStart) {
      switch (interval.type) {
        case IntervalType.warmup:
          // 不播报 warm-up（已在 start() 里播报“准备开始训练”）
          break;
        case IntervalType.rest:
          final prevWork = _previousWorkLabel(intervals, index);
          final nextWork = _nextWorkLabel(intervals, index);
          final isStepSwitchRest =
              prevWork != null && nextWork != null && prevWork != nextWork;
          if (isStepSwitchRest) {
            // 步骤结束后的休息：播报“步骤X结束，休息一下”
            // ignore: discarded_futures
            _tts.speakStepFinishedThenRest(prevWork);
          } else {
            // 组内休息 / 其它休息：仅播报“休息一下”
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
  
    // 不同类型对应不同提示音
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
    final calories = (state.total.inMinutes * 7.5).round();
    final record = WorkoutHistory.fromValues(
      planId: _sourceId,
      planTitle: _plan.title.isEmpty ? 'Workout' : _plan.title,
      startTime: _startedAtWall!,
      totalDurationSeconds: state.total.inSeconds,
      calories: calories,
      completionRate: state.intervals.isEmpty ? 0.0 : 1.0,
    );
    _historyRepo.save(record);
    // 异步同步至健康中心（Health Connect / HealthKit）
    // TODO: 暂时禁用 health 插件
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

/// 提供一个基于 WorkoutPlan 的 PlanWorkoutController。
///
/// 在 WorkoutView 中通过：
///   ref.watch(planWorkoutControllerProvider(args))
/// 获取到与当前 TimerPage 类似的状态。
final planWorkoutControllerProvider =
    StateNotifierProvider.autoDispose.family<PlanWorkoutController, TimerState, PlanWorkoutArgs>(
  (ref, args) => PlanWorkoutController(args.plan, args.language),
);

