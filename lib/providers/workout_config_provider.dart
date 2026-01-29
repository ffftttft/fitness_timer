import 'package:flutter/foundation.dart';

import '../core/persistence/workout_prefs.dart';
import '../models/workout_config.dart';

class WorkoutConfigProvider extends ChangeNotifier {
  WorkoutConfigProvider() {
    _load();
  }

  WorkoutConfig _config = WorkoutConfig.defaults();
  bool _loaded = false;

  WorkoutConfig get config => _config;
  bool get loaded => _loaded;

  Future<void> _load() async {
    final fromDisk = await WorkoutPrefs.loadConfig();
    if (fromDisk != null) {
      _config = fromDisk;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> update(WorkoutConfig next) async {
    _config = next;
    notifyListeners();
    await WorkoutPrefs.saveConfig(next);
  }
}

