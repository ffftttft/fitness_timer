import 'package:freezed_annotation/freezed_annotation.dart';

part 'interval_engine.freezed.dart';

/// 计时器状态（有限状态机）
enum TimerStatus {
  ready,
  running,
  paused,
  finished,
}

/// 间歇类型（先支持基础类型，后续可扩展 HIIT / EMOM 等）
enum IntervalType {
  warmup,
  work,
  rest,
  cooldown,
}

/// 单个间歇片段
@immutable
class Interval {
  const Interval({
    required this.duration,
    required this.type,
    this.label,
  });

  final Duration duration;
  final IntervalType type;
  final String? label;
}

/// 计时器当前快照
@freezed
class TimerState with _$TimerState {
  const factory TimerState({
    required TimerStatus status,
    required Duration total,
    required Duration elapsed,
    required Duration remaining,
    required int currentIntervalIndex,
    required List<Interval> intervals,
  }) = _TimerState;

  const TimerState._();

  bool get isFinished => status == TimerStatus.finished;
}

/// 单调时间源（从某个固定起点开始的持续时间）
typedef MonotonicNow = Duration Function();

/// 默认的单调时钟：基于 [Stopwatch]，不会受系统时间修改影响。
Duration _defaultMonotonicNow() {
  // 全局单例 stopwatch，避免重复启动带来的偏移
  // ignore: prefer_const_constructors
  final sw = _MonotonicStopwatchHolder.stopwatch;
  if (!sw.isRunning) sw.start();
  return sw.elapsed;
}

class _MonotonicStopwatchHolder {
  static final Stopwatch stopwatch = Stopwatch();
}

/// IntervalEngine：高精度计时引擎
///
/// - 使用单调时钟（[Stopwatch] 或注入的 [MonotonicNow]）驱动
/// - 不依赖 [DateTime.now]，避免用户/系统修改时间导致计时异常
/// - 支持多 Interval 串联（HIIT / Tabata / EMOM 等协议的基础）
class IntervalEngine {
  IntervalEngine({
    required List<Interval> intervals,
    MonotonicNow? now,
  })  : assert(intervals.isNotEmpty, 'Intervals must not be empty'),
        _intervals = List.unmodifiable(intervals),
        _now = now ?? _defaultMonotonicNow {
    _total = _intervals.fold<Duration>(
      Duration.zero,
      (sum, e) => sum + e.duration,
    );
    _cumulativeEnds = _buildCumulativeEnds(_intervals);
    _state = TimerState(
      status: TimerStatus.ready,
      total: _total,
      elapsed: Duration.zero,
      remaining: _total,
      currentIntervalIndex: 0,
      intervals: _intervals,
    );
  }

  final List<Interval> _intervals;
  final MonotonicNow _now;

  late final Duration _total;
  late final List<Duration> _cumulativeEnds;
  late TimerState _state;

  /// 单调时间起点（start 时记录）
  Duration? _startedAt;

  /// 累积的暂停总时长
  Duration _pausedAccumulated = Duration.zero;

  /// 最近一次进入暂停的时间（单调）
  Duration? _pauseStartedAt;

  TimerState get state => _state;

  /// 当前累积的暂停时长（供快照持久化使用）
  Duration get pausedAccumulated => _pausedAccumulated;

  /// 开始计时（仅在 [ready] 或 [finished] 时生效）
  void start() {
    if (_state.status == TimerStatus.running) return;

    if (_state.status == TimerStatus.finished) {
      _resetInternal();
    }

    _startedAt ??= _now();
    _pausedAccumulated = Duration.zero;
    _pauseStartedAt = null;

    _updateStateForNow(TimerStatus.running);
  }

  /// 暂停计时（仅在 [running] 时生效）
  void pause() {
    if (_state.status != TimerStatus.running) return;
    if (_pauseStartedAt == null) {
      _pauseStartedAt = _now();
    }
    _updateStateForNow(TimerStatus.paused);
  }

  /// 继续计时（仅在 [paused] 时生效）
  void resume() {
    if (_state.status != TimerStatus.paused) return;
    final pauseStartedAt = _pauseStartedAt;
    if (pauseStartedAt != null) {
      final now = _now();
      _pausedAccumulated += now - pauseStartedAt;
      _pauseStartedAt = null;
    }
    _updateStateForNow(TimerStatus.running);
  }

  /// 重置到初始状态（不修改 interval 列表）
  void reset() {
    _resetInternal();
  }

  /// 从快照恢复：用墙钟推算的 [recoveredElapsed] 与 [pausedAccumulated]、[wasPaused] 还原引擎状态。
  /// 用于断点续传：恢复后调用方应清空快照，避免循环恢复。
  void restoreFromSnapshot({
    required Duration recoveredElapsed,
    required Duration pausedAccumulated,
    required bool wasPaused,
  }) {
    final total = _total;
    if (recoveredElapsed >= total || recoveredElapsed.isNegative) {
      _forceFinished();
      return;
    }
    final now = _now();
    _startedAt = now - recoveredElapsed - pausedAccumulated;
    _pausedAccumulated = pausedAccumulated;
    _pauseStartedAt = wasPaused ? now : null;
    _updateStateForNow(wasPaused ? TimerStatus.paused : TimerStatus.running);
  }

  void _resetInternal() {
    _startedAt = null;
    _pausedAccumulated = Duration.zero;
    _pauseStartedAt = null;
    _state = TimerState(
      status: TimerStatus.ready,
      total: _total,
      elapsed: Duration.zero,
      remaining: _total,
      currentIntervalIndex: 0,
      intervals: _intervals,
    );
  }

  /// 外部定期调用，用于刷新状态（UI/BLoC/Riverpod 可在 ticker 中调用）
  void tick() {
    if (_state.status == TimerStatus.ready ||
        _state.status == TimerStatus.finished) {
      return;
    }
    final status =
        _state.status == TimerStatus.paused ? TimerStatus.paused : TimerStatus.running;
    _updateStateForNow(status);
  }

  /// 跳到下一个 interval（跨阶段切换），用于“跳过本组/本段”逻辑
  void skipCurrentInterval() {
    if (_state.isFinished) return;
    final currentIndex = _state.currentIntervalIndex;
    if (currentIndex >= _intervals.length - 1) {
      // 直接终止
      _forceFinished();
      return;
    }

    // 目标 elapsed = 当前 interval 结束时刻
    final targetElapsed = _cumulativeEnds[currentIndex];
    final now = _now();
    _startedAt = now - targetElapsed - _pausedAccumulated;
    _pauseStartedAt = null;
    _updateStateForNow(TimerStatus.running);
  }

  void _forceFinished() {
    _startedAt = null;
    _pauseStartedAt = null;
    _pausedAccumulated = Duration.zero;
    _state = _state.copyWith(
      status: TimerStatus.finished,
      elapsed: _total,
      remaining: Duration.zero,
      currentIntervalIndex: _intervals.length - 1,
    );
  }

  void _updateStateForNow(TimerStatus targetStatus) {
    final total = _total;
    if (total <= Duration.zero || _startedAt == null) {
      _state = _state.copyWith(
        status: targetStatus == TimerStatus.finished ? TimerStatus.finished : TimerStatus.ready,
        elapsed: Duration.zero,
        remaining: total,
        currentIntervalIndex: 0,
      );
      return;
    }

    final now = _now();
    var elapsed = now - _startedAt!;

    // 扣除已经累计的暂停时长
    elapsed -= _pausedAccumulated;

    // 如果当前正处于暂停阶段，扣除从进入暂停到当前的这段时间
    if (targetStatus == TimerStatus.paused && _pauseStartedAt != null) {
      elapsed -= now - _pauseStartedAt!;
    }

    if (elapsed.isNegative) {
      elapsed = Duration.zero;
    }
    if (elapsed >= total) {
      _forceFinished();
      return;
    }

    final remaining = total - elapsed;
    final index = _indexForElapsed(elapsed);

    _state = _state.copyWith(
      status: targetStatus,
      elapsed: elapsed,
      remaining: remaining,
      currentIntervalIndex: index,
    );
  }

  List<Duration> _buildCumulativeEnds(List<Interval> intervals) {
    final result = <Duration>[];
    var acc = Duration.zero;
    for (final interval in intervals) {
      acc += interval.duration;
      result.add(acc);
    }
    return List.unmodifiable(result);
  }

  int _indexForElapsed(Duration elapsed) {
    for (var i = 0; i < _cumulativeEnds.length; i++) {
      if (elapsed < _cumulativeEnds[i]) {
        return i;
      }
    }
    return _cumulativeEnds.length - 1;
  }
}

