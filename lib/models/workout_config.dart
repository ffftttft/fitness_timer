import 'package:flutter/foundation.dart';

@immutable
class WorkoutConfig {
  final int warmupSeconds;
  final int workSeconds;
  final int restSeconds;
  final int rounds;

  const WorkoutConfig({
    required this.warmupSeconds,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
  });

  factory WorkoutConfig.defaults() => const WorkoutConfig(
        warmupSeconds: 10,
        workSeconds: 30,
        restSeconds: 15,
        rounds: 8,
      );

  WorkoutConfig copyWith({
    int? warmupSeconds,
    int? workSeconds,
    int? restSeconds,
    int? rounds,
  }) {
    return WorkoutConfig(
      warmupSeconds: warmupSeconds ?? this.warmupSeconds,
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      rounds: rounds ?? this.rounds,
    );
  }

  Map<String, Object> toJson() => {
        'warmupSeconds': warmupSeconds,
        'workSeconds': workSeconds,
        'restSeconds': restSeconds,
        'rounds': rounds,
      };

  factory WorkoutConfig.fromJson(Map<Object?, Object?> json) {
    int readInt(String key, int fallback) {
      final v = json[key];
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    return WorkoutConfig(
      warmupSeconds: readInt('warmupSeconds', 10).clamp(0, 60 * 60),
      workSeconds: readInt('workSeconds', 30).clamp(1, 60 * 60),
      restSeconds: readInt('restSeconds', 15).clamp(0, 60 * 60),
      rounds: readInt('rounds', 8).clamp(1, 999),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutConfig &&
          warmupSeconds == other.warmupSeconds &&
          workSeconds == other.workSeconds &&
          restSeconds == other.restSeconds &&
          rounds == other.rounds;

  @override
  int get hashCode => Object.hash(warmupSeconds, workSeconds, restSeconds, rounds);
}

