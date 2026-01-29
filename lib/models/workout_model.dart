import 'package:flutter/foundation.dart';

/// Internal timeline entry used during playback (derived from plan items).
@immutable
class WorkoutStep {
  final String id;
  final String name;
  final int durationSeconds;
  final WorkoutStepType type;

  const WorkoutStep({
    required this.id,
    required this.name,
    required this.durationSeconds,
    required this.type,
  });
}

enum WorkoutStepType {
  work,
  rest,
}

/// Time unit for plan configuration.
enum PlanTimeUnit {
  h,
  min,
  s,
}

@immutable
class PlanItem {
  final String id;
  final String name;
  final int sets;
  final int perSetValue;
  final PlanTimeUnit perSetUnit;
  final int intraRestValue;
  final PlanTimeUnit intraRestUnit;
  final int interRestValue;
  final PlanTimeUnit interRestUnit;

  const PlanItem({
    required this.id,
    required this.name,
    required this.sets,
    required this.perSetValue,
    required this.perSetUnit,
    required this.intraRestValue,
    required this.intraRestUnit,
    required this.interRestValue,
    required this.interRestUnit,
  });

  PlanItem copyWith({
    String? id,
    String? name,
    int? sets,
    int? perSetValue,
    PlanTimeUnit? perSetUnit,
    int? intraRestValue,
    PlanTimeUnit? intraRestUnit,
    int? interRestValue,
    PlanTimeUnit? interRestUnit,
  }) {
    return PlanItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      perSetValue: perSetValue ?? this.perSetValue,
      perSetUnit: perSetUnit ?? this.perSetUnit,
      intraRestValue: intraRestValue ?? this.intraRestValue,
      intraRestUnit: intraRestUnit ?? this.intraRestUnit,
      interRestValue: interRestValue ?? this.interRestValue,
      interRestUnit: interRestUnit ?? this.interRestUnit,
    );
  }

  int _toSeconds(int value, PlanTimeUnit unit) {
    if (value <= 0) return 0;
    switch (unit) {
      case PlanTimeUnit.h:
        return value * 3600;
      case PlanTimeUnit.min:
        return value * 60;
      case PlanTimeUnit.s:
        return value;
    }
  }

  int get perSetSeconds => _toSeconds(perSetValue, perSetUnit);

  int get intraRestSeconds => _toSeconds(intraRestValue, intraRestUnit);

  int get interRestSeconds => _toSeconds(interRestValue, interRestUnit);

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'sets': sets,
        'perSetValue': perSetValue,
        'perSetUnit': perSetUnit.name,
        'intraRestValue': intraRestValue,
        'intraRestUnit': intraRestUnit.name,
        'interRestValue': interRestValue,
        'interRestUnit': interRestUnit.name,
      };

  factory PlanItem.fromJson(Map<String, Object?> json) {
    PlanTimeUnit unitFrom(String? v, PlanTimeUnit fallback) {
      return PlanTimeUnit.values
          .firstWhere((e) => e.name == v, orElse: () => fallback);
    }

    final id = (json['id'] as String?) ?? UniqueKey().toString();
    final name = (json['name'] as String?) ?? '';
    final sets = (json['sets'] as int?) ?? 1;
    final perSetValue = (json['perSetValue'] as int?) ?? 30;
    final perSetUnit =
        unitFrom(json['perSetUnit'] as String?, PlanTimeUnit.s);
    final intraRestValue = (json['intraRestValue'] as int?) ?? 0;
    final intraRestUnit =
        unitFrom(json['intraRestUnit'] as String?, PlanTimeUnit.s);
    final interRestValue = (json['interRestValue'] as int?) ?? 0;
    final interRestUnit =
        unitFrom(json['interRestUnit'] as String?, PlanTimeUnit.s);

    return PlanItem(
      id: id,
      name: name,
      sets: sets.clamp(1, 999),
      perSetValue: perSetValue.clamp(1, 60 * 60),
      perSetUnit: perSetUnit,
      intraRestValue: intraRestValue.clamp(0, 60 * 60),
      intraRestUnit: intraRestUnit,
      interRestValue: interRestValue.clamp(0, 60 * 60),
      interRestUnit: interRestUnit,
    );
  }
}

@immutable
class WorkoutPlan {
  final String id;
  final String title;
  final String description;
  /// Warm-up time in seconds before the first plan item starts.
  final int warmupSeconds;
  /// Items inside this plan group (each item has sets / per-set duration / rests).
  final List<PlanItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkoutPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.warmupSeconds,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  WorkoutPlan copyWith({
    String? id,
    String? title,
    String? description,
    int? warmupSeconds,
    List<PlanItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      warmupSeconds: warmupSeconds ?? this.warmupSeconds,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get totalDurationSeconds {
    final warm = warmupSeconds.clamp(0, 24 * 60 * 60);
    final body = items.fold<int>(0, (sum, item) {
      final perSet = item.perSetSeconds;
      final intra = item.intraRestSeconds;
      final inter = item.interRestSeconds;
      final sets = item.sets.clamp(1, 999);
      final workTotal = perSet * sets;
      final intraTotal = sets > 1 ? intra * (sets - 1) : 0;
      return sum + workTotal + intraTotal + inter;
    });
    return warm + body;
  }

  int get stepCount => items.length;

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'warmupSeconds': warmupSeconds,
        'items': items.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WorkoutPlan.fromJson(Map<String, Object?> json) {
    final id = (json['id'] as String?) ?? UniqueKey().toString();
    final title = (json['title'] as String?) ?? '';
    final description = (json['description'] as String?) ?? '';
    final warmup = (json['warmupSeconds'] as int?) ?? 0;
    final itemsJson = json['items'] as List<Object?>? ?? const [];
    final items = itemsJson
        .whereType<Map<String, Object?>>()
        .map(PlanItem.fromJson)
        .toList(growable: false);
    DateTime parseDate(String key) {
      final str = json[key] as String?;
      if (str == null) return DateTime.now();
      return DateTime.tryParse(str) ?? DateTime.now();
    }

    return WorkoutPlan(
      id: id,
      title: title,
      description: description,
      warmupSeconds: warmup.clamp(0, 24 * 60 * 60),
      items: items,
      createdAt: parseDate('createdAt'),
      updatedAt: parseDate('updatedAt'),
    );
  }
}

