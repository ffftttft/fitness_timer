import 'package:freezed_annotation/freezed_annotation.dart';

part 'interval_engine.freezed.dart';

/// Timer status (finite state machine).
enum TimerStatus {
  ready,
  running,
  paused,
  finished,
}

/// Interval type (base types; extendable for HIIT / EMOM etc.).
enum IntervalType {
  warmup,
  work,
  rest,
  cooldown,
}

/// A single interval segment.
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

/// Current timer snapshot.
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

/// Monotonic time source (duration from a fixed start).
typedef MonotonicNow = Duration Function();

/// Default monotonic clock: [Stopwatch]-based, unaffected by system time changes.
Duration _defaultMonotonicNow() {
  // Global stopwatch to avoid drift from multiple starts
  // ignore: prefer_const_constructors
  final sw = _MonotonicStopwatchHolder.stopwatch;
  if (!sw.isRunning) sw.start();
  return sw.elapsed;
}

class _MonotonicStopwatchHolder {
  static final Stopwatch stopwatch = Stopwatch();
}

/// High-precision interval timer engine.
///
/// - Driven by monotonic clock ([Stopwatch] or injected [MonotonicNow])
/// - Does not use [DateTime.now], so user/system time changes do not affect timing
/// - Supports multiple intervals in sequence (basis for HIIT / Tabata / EMOM etc.)
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

  /// Monotonic time at start (recorded on start).
  Duration? _startedAt;

  /// Total accumulated pause duration.
  Duration _pausedAccumulated = Duration.zero;

  /// Monotonic time when pause was entered.
  Duration? _pauseStartedAt;

  TimerState get state => _state;

  /// Current accumulated pause (for snapshot persistence).
  Duration get pausedAccumulated => _pausedAccumulated;

  /// Start timing (only when [ready] or [finished]).
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

  /// Pause timing (only when [running]).
  void pause() {
    if (_state.status != TimerStatus.running) return;
    if (_pauseStartedAt == null) {
      _pauseStartedAt = _now();
    }
    _updateStateForNow(TimerStatus.paused);
  }

  /// Resume timing (only when [paused]).
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

  /// Reset to initial state (interval list unchanged).
  void reset() {
    _resetInternal();
  }

  /// Restore from snapshot: [recoveredElapsed], [pausedAccumulated], [wasPaused] restore engine state.
  /// Caller should clear snapshot after restore to avoid repeated recovery.
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

  /// Call periodically to refresh state (e.g. from UI/BLoC/Riverpod ticker).
  void tick() {
    if (_state.status == TimerStatus.ready ||
        _state.status == TimerStatus.finished) {
      return;
    }
    final status =
        _state.status == TimerStatus.paused ? TimerStatus.paused : TimerStatus.running;
    _updateStateForNow(status);
  }

  /// Skip to next interval (phase change); "skip current set/segment" behavior.
  void skipCurrentInterval() {
    if (_state.isFinished) return;
    final currentIndex = _state.currentIntervalIndex;
    if (currentIndex >= _intervals.length - 1) {
      _forceFinished();
      return;
    }

    // Target elapsed = end of current interval
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

    elapsed -= _pausedAccumulated;

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

/// Total duration of Work intervals within [elapsed] (warmup and rest excluded for calorie).
Duration workElapsedWithin(List<Interval> intervals, Duration elapsed) {
  var cumulative = Duration.zero;
  var work = Duration.zero;
  for (final interval in intervals) {
    final intervalEnd = cumulative + interval.duration;
    if (interval.type == IntervalType.work) {
      if (elapsed >= intervalEnd) {
        work += interval.duration;
      } else if (elapsed > cumulative) {
        work += elapsed - cumulative;
      }
    }
    cumulative = intervalEnd;
  }
  return work;
}