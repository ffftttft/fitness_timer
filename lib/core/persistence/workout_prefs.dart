import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/workout_config.dart';

class WorkoutPrefs {
  WorkoutPrefs._();

  static const _kConfigKey = 'workout_config_v1';

  static Future<WorkoutConfig?> loadConfig() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kConfigKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      if (json is Map) {
        return WorkoutConfig.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  static Future<void> saveConfig(WorkoutConfig config) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kConfigKey, jsonEncode(config.toJson()));
  }
}

