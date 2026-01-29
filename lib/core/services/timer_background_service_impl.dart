import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/models/foreground_task_event_action.dart';

import 'timer_background_service.dart';

/// Foreground service implementation using [flutter_foreground_task].
///
/// - On timer start, [startService] starts the foreground service; TaskHandler runs in a background isolate.
/// - Main isolate calls [updateNotification] once per second, which uses [FlutterForegroundTask.sendDataToTask];
///   TaskHandler [onReceiveData] updates the notification countdown (MM:SS).
/// - On pause/reset/finish, [stopService] stops the foreground service.
class TimerBackgroundServiceImpl implements TimerBackgroundService {
  TimerBackgroundServiceImpl._();
  static final TimerBackgroundServiceImpl _instance =
      TimerBackgroundServiceImpl._();
  factory TimerBackgroundServiceImpl() => _instance;

  static const String _channelId = 'fitness_timer_foreground';
  static const String _channelName = 'Fitness Timer';

  bool _running = false;

  @override
  Future<void> startService() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (_running) return;
    _running = true;
    await FlutterForegroundTask.startService(
      notificationTitle: 'Fitness Timer',
      notificationText: '00:00',
    );
  }

  @override
  Future<void> stopService() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (!_running) return;
    _running = false;
    await FlutterForegroundTask.stopService();
  }

  @override
  Future<void> updateNotification(String title, String body) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (!_running) return;
    FlutterForegroundTask.sendDataToTask({'title': title, 'body': body});
  }

  /// Called from [main] or DI init: configure foreground task and register TaskHandler entry point.
  static Future<void> initForegroundTask() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: _channelId,
        channelName: _channelName,
        channelDescription: 'Fitness timer countdown when running in background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
      ),
    );
  }
}
