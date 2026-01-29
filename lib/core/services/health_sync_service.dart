import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// Sync a single workout result to the system health store (Android Health Connect / iOS HealthKit).
///
/// Controller calls [uploadWorkout] when [TimerStatus.finished]; writes duration and estimated calories (minutes * 7.5).
abstract class HealthSyncService {
  /// Request write permission for health data (call before writing; e.g. from settings or after first completed workout).
  Future<bool> requestAuthorization();

  /// Upload one workout: [duration], [calories], optional [workoutTitle]. On failure, log and do not block UI.
  Future<void> uploadWorkout({
    required Duration duration,
    required int calories,
    String? workoutTitle,
    DateTime? startTime,
  });
}

class HealthSyncServiceImpl implements HealthSyncService {
  HealthSyncServiceImpl._();
  static final HealthSyncServiceImpl _instance = HealthSyncServiceImpl._();
  factory HealthSyncServiceImpl() => _instance;

  final Health _health = Health();

  static final List<HealthDataType> _typesToWrite = [
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  @override
  Future<bool> requestAuthorization() async {
    try {
      final granted = await _health.requestAuthorization(
        _typesToWrite,
        permissions: [
          HealthDataAccess.WRITE,
          HealthDataAccess.READ,
        ],
      );
      return granted;
    } catch (e, st) {
      debugPrint('HealthSyncService.requestAuthorization: $e $st');
      return false;
    }
  }

  @override
  Future<void> uploadWorkout({
    required Duration duration,
    required int calories,
    String? workoutTitle,
    DateTime? startTime,
  }) async {
    final start = startTime ?? DateTime.now().subtract(duration);
    final end = start.add(duration);

    try {
      // Write ACTIVE_ENERGY_BURNED (calories) to Health Connect / HealthKit
      await _health.writeHealthData(
        value: calories.toDouble(),
        type: HealthDataType.ACTIVE_ENERGY_BURNED,
        startTime: start,
        endTime: end,
      );
    } catch (e, st) {
      debugPrint('HealthSyncService.uploadWorkout: $e $st');
    }
  }
}
