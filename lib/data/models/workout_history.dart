import 'package:isar/isar.dart';

part 'workout_history.g.dart';

/// Single workout history record (Isar-persisted).
///
/// - [planId]: plan ID (config hash for simple timer, WorkoutPlan.id for plan workout)
/// - [planTitle]: plan title (for display)
/// - [startTime]: start time, indexed for time-ordered queries
/// - [totalDuration]: total workout duration (seconds)
/// - [calories]: rough estimate (minutes * 7)
/// - [completionRate]: completed intervals / total intervals (0.0–1.0)
@collection
class WorkoutHistory {
  Id id = Isar.autoIncrement;

  late String planId;
  late String planTitle;

  @Index()
  late DateTime startTime;

  late int totalDurationSeconds;
  late int calories;
  late double completionRate;

  WorkoutHistory();

  factory WorkoutHistory.fromValues({
    required String planId,
    required String planTitle,
    required DateTime startTime,
    required int totalDurationSeconds,
    required int calories,
    required double completionRate,
  }) {
    final h = WorkoutHistory();
    h.planId = planId;
    h.planTitle = planTitle;
    h.startTime = startTime;
    h.totalDurationSeconds = totalDurationSeconds;
    h.calories = calories;
    h.completionRate = completionRate;
    return h;
  }
}
