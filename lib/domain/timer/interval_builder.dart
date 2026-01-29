import 'package:flutter/foundation.dart';

import '../../models/workout_config.dart';

import 'interval_engine.dart';

/// Builds a generic list of [Interval] from a simple [WorkoutConfig].
///
/// Matches TimerProvider warmup / work / rest / rounds semantics:
/// - warmupSeconds > 0: single warm-up before plan, once;
/// - rounds: repeat work + (rest, except after last round);
@immutable
class WorkoutConfigIntervalBuilder {
  const WorkoutConfigIntervalBuilder(this.config);

  final WorkoutConfig config;

  List<Interval> build() {
    final intervals = <Interval>[];

    final warmup = config.warmupSeconds.clamp(0, 60 * 60);
    final work = config.workSeconds.clamp(1, 60 * 60);
    final rest = config.restSeconds.clamp(0, 60 * 60);
    final rounds = config.rounds.clamp(1, 999);

    if (warmup > 0) {
      intervals.add(
        Interval(
          duration: Duration(seconds: warmup),
          type: IntervalType.warmup,
          label: 'Warm-up',
        ),
      );
    }

    for (var round = 0; round < rounds; round++) {
      // work
      intervals.add(
        Interval(
          duration: Duration(seconds: work),
          type: IntervalType.work,
          label: 'Work',
        ),
      );

      final isLastRound = round == rounds - 1;
      if (!isLastRound && rest > 0) {
        intervals.add(
          Interval(
            duration: Duration(seconds: rest),
            type: IntervalType.rest,
            label: 'Rest',
          ),
        );
      }
    }

    return List.unmodifiable(intervals);
  }
}

