import 'package:isar/isar.dart';

part 'workout_history.g.dart';

/// 单次训练历史记录（Isar 持久化）。
///
/// - [planId]: 计划 ID（简单计时可为配置哈希，计划训练为 WorkoutPlan.id）
/// - [planTitle]: 计划标题（展示用）
/// - [startTime]: 开始时间，带索引便于按时间查询
/// - [totalDuration]: 计划总时长（秒）
/// - [calories]: 粗略估算（minutes * 7）
/// - [completionRate]: 已完成 interval 数 / 总 interval 数（0.0～1.0）
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
