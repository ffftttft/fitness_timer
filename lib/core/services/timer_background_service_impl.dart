import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/models/foreground_task_event_action.dart';

import 'timer_background_service.dart';

/// 基于 [flutter_foreground_task] 的前台服务实现。
///
/// - 计时器 start 时 [startService] 启动前台服务，TaskHandler 在后台 Isolate 中运行。
/// - 主 isolate 每秒通过 [updateNotification] 调用 [FlutterForegroundTask.sendDataToTask]，
///   TaskHandler [onReceiveData] 收到后更新通知栏倒计时（MM:SS）。
/// - 暂停/重置/完成时 [stopService] 停止前台服务。
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

  /// 供 [main] 或 DI 初始化时调用：配置前台任务并注册 TaskHandler 入口。
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
