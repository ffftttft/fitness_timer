import 'package:flutter/foundation.dart';

import '../../models/workout_model.dart';

import 'interval_engine.dart';

/// 根据 WorkoutPlan 构建一组通用的 [Interval] 列表。
///
/// 规则对齐当前 PlanWorkoutProvider._buildTimeline：
/// - 整体 warmupSeconds > 0: 作为单独的 Warm-up Interval；
/// - 每个 PlanItem 展开为：
///   - N 组 work（perSetSeconds）；
///   - 组间休息（intraRestSeconds），所有非最后一组；
///   - 计划间休息（interRestSeconds），在该 item 完成后。
@immutable
class PlanIntervalBuilder {
  const PlanIntervalBuilder(this.plan);

  final WorkoutPlan plan;

  List<Interval> build() {
    final intervals = <Interval>[];

    final warmup = plan.warmupSeconds.clamp(0, 24 * 60 * 60);
    if (warmup > 0) {
      intervals.add(
        Interval(
          duration: Duration(seconds: warmup),
          type: IntervalType.warmup,
          label: 'Warm-up',
        ),
      );
    }

    for (final item in plan.items) {
      final sets = item.sets.clamp(1, 999);
      final perSet = item.perSetSeconds;
      final intra = item.intraRestSeconds;
      final inter = item.interRestSeconds;

      for (var i = 0; i < sets; i++) {
        if (perSet > 0) {
          intervals.add(
            Interval(
              duration: Duration(seconds: perSet),
              type: IntervalType.work,
              label: item.name, // 只显示步骤名，不显示进度
            ),
          );
        }

        final isLastSet = i == sets - 1;
        if (!isLastSet && intra > 0) {
          intervals.add(
            Interval(
              duration: Duration(seconds: intra),
              type: IntervalType.rest,
              label: 'Rest',
            ),
          );
        }
      }

      if (inter > 0) {
        intervals.add(
          Interval(
            duration: Duration(seconds: inter),
            type: IntervalType.rest,
            label: 'Rest',
          ),
        );
      }
    }

    return List.unmodifiable(intervals);
  }
}

