import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// 将单次训练结果同步至系统健康中心（Android Health Connect / iOS HealthKit）。
///
/// 在 [TimerStatus.finished] 时由控制器调用 [uploadWorkout]，
/// 写入锻炼时长与估算卡路里（minutes * 7.5）。
abstract class HealthSyncService {
  /// 请求健康数据写入权限（需在写入前调用，建议在设置页或首次完成训练时引导）。
  Future<bool> requestAuthorization();

  /// 上传一次训练记录：时长 [duration]、卡路里 [calories]、可选 [workoutTitle]。
  /// 失败时静默或记录日志，不阻塞 UI。
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
      // 写入 ACTIVE_ENERGY_BURNED（卡路里），同步至 Health Connect / HealthKit
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
