import 'package:isar/isar.dart';

part 'timer_snapshot.g.dart';

/// Timer snapshot kind: simple timer or plan workout.
enum TimerSnapshotKind {
  simple,
  plan,
}

/// Timer state snapshot entity for resume-after-interrupt.
///
/// - [kind]: simple = simple timer, plan = plan workout
/// - [sourceId]: config hash for simple, planId for plan
/// - [status]: 0=ready, 1=running, 2=paused, 3=finished
/// - [startedAtWall]: wall-clock time when timer started
/// - [lastUpdatedAtWall]: wall-clock time of last snapshot write
/// - [elapsedAtLastUpdateMicros]: elapsed duration at last update (micros)
/// - [pausedAccumulatedMicros]: total paused duration (micros)
/// - [currentIntervalIndex]: current interval index
@collection
class TimerSnapshot {
  Id id = Isar.autoIncrement;

  /// simple | plan
  late String kind;

  /// 配置哈希或计划 ID
  late String sourceId;

  /// TimerStatus.index: 0=ready, 1=running, 2=paused, 3=finished
  late int status;

  late DateTime startedAtWall;
  late DateTime lastUpdatedAtWall;

  /// Duration.inMicroseconds
  late int elapsedAtLastUpdateMicros;
  late int pausedAccumulatedMicros;

  late int currentIntervalIndex;

  TimerSnapshot();

  /// Build from business fields (for controller to persist)
  factory TimerSnapshot.fromValues({
    required String kind,
    required String sourceId,
    required int status,
    required DateTime startedAtWall,
    required DateTime lastUpdatedAtWall,
    required Duration elapsedAtLastUpdate,
    required Duration pausedAccumulated,
    required int currentIntervalIndex,
  }) {
    final s = TimerSnapshot();
    s.kind = kind;
    s.sourceId = sourceId;
    s.status = status;
    s.startedAtWall = startedAtWall;
    s.lastUpdatedAtWall = lastUpdatedAtWall;
    s.elapsedAtLastUpdateMicros = elapsedAtLastUpdate.inMicroseconds;
    s.pausedAccumulatedMicros = pausedAccumulated.inMicroseconds;
    s.currentIntervalIndex = currentIntervalIndex;
    return s;
  }

  @ignore
  Duration get elapsedAtLastUpdate =>
      Duration(microseconds: elapsedAtLastUpdateMicros);

  @ignore
  Duration get pausedAccumulated =>
      Duration(microseconds: pausedAccumulatedMicros);
}
