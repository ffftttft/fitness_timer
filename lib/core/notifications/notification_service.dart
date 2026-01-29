import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _androidChannelId = 'fitness_timer_channel';

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      final String name =
          (tzInfo is String ? tzInfo : (tzInfo as dynamic).name) as String;
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // fallback: keep default timezone
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _androidChannelId,
        'Fitness Timer',
        description: 'Phase end reminders',
        importance: Importance.max,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  static Future<void> cancelAll() => _plugin.cancelAll();

  static Future<void> schedulePhaseEnd({
    required DateTime when,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    final tzWhen = tz.TZDateTime.from(when, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        'Fitness Timer',
        channelDescription: 'Phase end reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: 1001,
      title: title,
      body: body,
      scheduledDate: tzWhen,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}

