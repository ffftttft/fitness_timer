import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../models/workout_model.dart';

class WorkoutPlanStorage {
  WorkoutPlanStorage._();

  static const _fileName = 'workout_plans.json';

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<List<WorkoutPlan>> loadPlans() async {
    try {
      final file = await _file();
      if (!await file.exists()) return const [];
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return const [];
      final json = jsonDecode(raw);
      if (json is List) {
        return json
            .whereType<Map<String, Object?>>()
            .map(WorkoutPlan.fromJson)
            .toList(growable: true);
      }
    } catch (_) {
      // ignore and return empty
    }
    return const [];
  }

  static Future<void> savePlans(List<WorkoutPlan> plans) async {
    final file = await _file();
    final json = plans.map((p) => p.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }
}

