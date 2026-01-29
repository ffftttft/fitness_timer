import 'package:flutter/foundation.dart';

import '../core/persistence/workout_plan_storage.dart';
import '../models/workout_model.dart';

class WorkoutPlanProvider extends ChangeNotifier {
  WorkoutPlanProvider() {
    _load();
  }

  final List<WorkoutPlan> _plans = [];
  bool _loaded = false;

  List<WorkoutPlan> get plans => List.unmodifiable(_plans);
  bool get loaded => _loaded;

  Future<void> _load() async {
    final items = await WorkoutPlanStorage.loadPlans();
    _plans
      ..clear()
      ..addAll(items);
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    await WorkoutPlanStorage.savePlans(_plans);
  }

  Future<void> addOrUpdate(WorkoutPlan plan) async {
    final index = _plans.indexWhere((p) => p.id == plan.id);
    if (index >= 0) {
      _plans[index] = plan.copyWith(updatedAt: DateTime.now());
    } else {
      _plans.add(plan.copyWith(updatedAt: DateTime.now()));
    }
    notifyListeners();
    await _persist();
  }

  Future<void> deletePlan(String id) async {
    _plans.removeWhere((p) => p.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> reorderPlans(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final plan = _plans.removeAt(oldIndex);
    _plans.insert(newIndex, plan);
    notifyListeners();
    await _persist();
  }

  WorkoutPlan? getById(String id) {
    try {
      return _plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

