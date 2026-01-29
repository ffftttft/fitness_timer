import 'package:flutter/foundation.dart';

import '../../models/workout_config.dart';

import 'interval_engine.dart';

/// 根据简单的 WorkoutConfig 构建一组通用的 [Interval] 列表。
///
/// 对应当前 TimerProvider 的 warmup / work / rest / rounds 语义：
/// - warmupSeconds > 0: 计划前的统一热身，仅一次；
/// - rounds: work + (rest, 除最后一轮外) 的重复；
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

