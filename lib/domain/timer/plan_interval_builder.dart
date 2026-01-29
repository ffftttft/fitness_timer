import 'package:flutter/foundation.dart';

import '../../models/workout_model.dart';

import 'interval_engine.dart';

/// Builds a generic list of [Interval] from a [WorkoutPlan].
///
/// Rules aligned with PlanWorkoutProvider._buildTimeline:
/// - Global warmupSeconds > 0: single Warm-up interval at start;
/// - Each PlanItem expands to:
///   - N sets of work (perSetSeconds);
///   - Intra-set rest (intraRestSeconds) after each set except the last;
///   - Inter-item rest (interRestSeconds) after the item completes.
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
              label: item.name, // step name only, no set index
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

