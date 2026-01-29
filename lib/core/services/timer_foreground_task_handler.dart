import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// 前台任务 Handler：在后台 Isolate 中运行，接收主 isolate 推送的计时器状态并更新通知。
///
/// 状态同步流程：主 isolate 计时器每 200ms tick，每秒通过 [FlutterForegroundTask.sendDataToTask]
/// 推送当前剩余时间（MM:SS）；本 Handler 的 [onReceiveData] 收到后调用 [FlutterForegroundTask.updateService]
/// 更新通知栏文案，实现「主 isolate 状态 → 后台 isolate 通知」的同步。
///
/// 异常监控：onReceiveData 中包裹 try-catch，将后台 Isolate 异常上报 Sentry，避免静默失败。
@pragma('vm:entry-point')
void startTimerForegroundTask() {
  FlutterForegroundTask.setTaskHandler(TimerForegroundTaskHandler());
}

class TimerForegroundTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      // 初始通知由 startTask(initData) 传入。若需在后台 Isolate 内读快照以保持数据一致，
      // 可在此通过 initData 传入 databasePath，再 Isar.openAsync([TimerSnapshotSchema], path: databasePath)
      // 或使用 Isar.getInstance()（若插件在同一进程内创建 isolate）；当前采用主 isolate 每秒 sendDataToTask 推送状态。
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
    // 任务结束，可做清理
  }

  @override
  void onReceiveData(Object data) {
    try {
      // 主 isolate 每秒推送 { 'title': String, 'body': String }（body 为 MM:SS 倒计时）
      if (data is! Map) return;
      final title = data['title'] as String? ?? 'Fitness Timer';
      final body = data['body'] as String? ?? '00:00';
      FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: body,
      );
    } catch (e, st) {
      // 后台 Isolate 异常上报，便于生产环境排查（如 Android 14+ 权限缺失导致 SecurityException）
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
