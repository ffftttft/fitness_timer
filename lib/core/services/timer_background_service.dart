/// 计时器后台/前台服务抽象接口
///
/// 为应对 Android 14+ 严格后台限制，预留此后台服务抽象。
/// 后续可接入 [flutter_foreground_task] 等实现，保证锁屏下仍能维持约 200ms 的 Tick 更新。
abstract class TimerBackgroundService {
  /// 启动后台/前台服务（如前台通知与保活）
  Future<void> startService();

  /// 停止服务并释放资源
  Future<void> stopService();

  /// 更新通知栏文案（运行中时展示当前阶段/剩余时间等）
  Future<void> updateNotification(String title, String body);
}
