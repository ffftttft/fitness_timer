import 'package:flutter/foundation.dart';

import 'notification_service.dart' as static_service;

/// Notification service interface for DI and testing.
abstract class TimerNotificationService {
  Future<void> init();

  Future<void> cancelAll();

  Future<void> schedulePhaseEnd({
    required DateTime when,
    required String title,
    required String body,
  });
}

/// Default implementation using the existing [NotificationService] static API.
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

