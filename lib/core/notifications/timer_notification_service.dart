import 'package:flutter/foundation.dart';

import 'notification_service.dart' as static_service;

/// 抽象出的通知服务接口，方便通过 DI 注入与单元测试替换。
abstract class TimerNotificationService {
  Future<void> init();

  Future<void> cancelAll();

  Future<void> schedulePhaseEnd({
    required DateTime when,
    required String title,
    required String body,
  });
}

/// 基于现有 [NotificationService] 静态工具的默认实现。
@immutable
class TimerNotificationServiceImpl implements TimerNotificationService {
  const TimerNotificationServiceImpl();

  @override
  Future<void> init() => static_service.NotificationService.init();

  @override
  Future<void> cancelAll() => static_service.NotificationService.cancelAll();

  @override
  Future<void> schedulePhaseEnd({
    required DateTime when,
    required String title,
    required String body,
  }) {
    return static_service.NotificationService.schedulePhaseEnd(
      when: when,
      title: title,
      body: body,
    );
  }
}

