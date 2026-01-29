import 'package:flutter/foundation.dart';

enum ExerciseWorkType { time, reps }
enum TimeUnit { s, min }
enum RestKind { intraSet, betweenExercise }

@immutable
class PlanGroup {
  final String name;
  final List<Exercise> exercises;

  const PlanGroup({
    required this.name,
    required this.exercises,
  });

  PlanGroup copyWith({
    String? name,
    List<Exercise>? exercises,
  }) {
    return PlanGroup(
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
    );
  }
}

@immutable
class Exercise {
  final String id;
  final String name;
  final ExerciseWorkType workType;
  final int workValue;
  final TimeUnit workUnit; // 仅当 workType==time 时有意义；默认 s
  final int workSeconds; // 计时用（统一换算成秒）
  final int sets;
  // 组内休息（同一动作每组之间）
  final int intraRestValue;
  final TimeUnit intraRestUnit; // 默认 s
  final int intraRestSeconds; // 计时用（统一换算成秒）
  // 组间休息（不同动作之间）
  final int interRestValue;
  final TimeUnit interRestUnit; // 默认 s
  final int interRestSeconds; // 计时用（统一换算成秒）

  const Exercise({
    required this.id,
    required this.name,
    required this.workType,
    required this.workValue,
    required this.workUnit,
    required this.workSeconds,
    required this.sets,
    required this.intraRestValue,
    required this.intraRestUnit,
    required this.intraRestSeconds,
    required this.interRestValue,
    required this.interRestUnit,
    required this.interRestSeconds,
  });

  Exercise copyWith({
    String? id,
    String? name,
    ExerciseWorkType? workType,
    int? workValue,
    TimeUnit? workUnit,
    int? workSeconds,
    int? sets,
    int? intraRestValue,
    TimeUnit? intraRestUnit,
    int? intraRestSeconds,
    int? interRestValue,
    TimeUnit? interRestUnit,
    int? interRestSeconds,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      workType: workType ?? this.workType,
      workValue: workValue ?? this.workValue,
      workUnit: workUnit ?? this.workUnit,
      workSeconds: workSeconds ?? this.workSeconds,
      sets: sets ?? this.sets,
      intraRestValue: intraRestValue ?? this.intraRestValue,
      intraRestUnit: intraRestUnit ?? this.intraRestUnit,
      intraRestSeconds: intraRestSeconds ?? this.intraRestSeconds,
      interRestValue: interRestValue ?? this.interRestValue,
      interRestUnit: interRestUnit ?? this.interRestUnit,
      interRestSeconds: interRestSeconds ?? this.interRestSeconds,
    );
  }

  String get displaySummary {
    final workText = workType == ExerciseWorkType.time
        ? '$workValue ${workUnit == TimeUnit.s ? 's' : 'min'}'
        : '$workValue 次';
    final parts = <String>[];
    final safeSets = sets <= 0 ? 1 : sets;
    parts.add('$workText × $safeSets 组');

    if (intraRestValue > 0 && safeSets > 1) {
      final intraText =
          '$intraRestValue${intraRestUnit == TimeUnit.s ? 's' : 'min'}';
      parts.add('组内休息 $intraText');
    }
    if (interRestValue > 0) {
      final interText =
          '$interRestValue${interRestUnit == TimeUnit.s ? 's' : 'min'}';
      parts.add('组间休息 $interText');
    }
    return parts.join('，');
  }
}

int secondsFrom(int value, TimeUnit unit) {
  if (value <= 0) return 0;
  return unit == TimeUnit.min ? value * 60 : value;
}
