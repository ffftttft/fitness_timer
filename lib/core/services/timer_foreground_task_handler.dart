import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Foreground task handler: runs in a background isolate, receives timer state from main isolate and updates the notification.
///
/// Sync flow: main isolate ticks every 200ms and once per second calls [FlutterForegroundTask.sendDataToTask]
/// with current remaining time (MM:SS); this handler's [onReceiveData] then calls [FlutterForegroundTask.updateService]
/// to update the notification text (main isolate state → background isolate notification).
///
/// Errors in onReceiveData are caught and reported to Sentry to avoid silent failure.
@pragma('vm:entry-point')
void startTimerForegroundTask() {
  FlutterForegroundTask.setTaskHandler(TimerForegroundTaskHandler());
}

class TimerForegroundTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      // Initial notification comes from startTask(initData). To read snapshots in this isolate for consistency,
      // pass databasePath via initData and use Isar.openAsync([TimerSnapshotSchema], path: databasePath)
      // or Isar.getInstance() if the plugin uses the same process; currently main isolate pushes state via sendDataToTask every second.
    } catch (e, st) {
      Sentry.captureException(e, stackTrace: st);
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    try {
      // 若使用 eventInterval 定时触发，可在此做周期性逻辑；当前采用主 isolate 每秒 sendDataToTask 推送
    } catch (e, st) {
      Sentry.captureException(e, stackTrace: st);
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // Task ended; optional cleanup
  }

  @override
  void onReceiveData(Object data) {
    try {
      // Main isolate sends { 'title': String, 'body': String } every second (body = MM:SS countdown)
      if (data is! Map) return;
      final title = data['title'] as String? ?? 'Fitness Timer';
      final body = data['body'] as String? ?? '00:00';
      FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: body,
      );
    } catch (e, st) {
      // Report background isolate errors to Sentry for debugging (e.g. Android 14+ permission SecurityException)
      Sentry.captureException(e, stackTrace: st);
    }
  }

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {}

  @override
  void onNotificationDismissed() {}
}
