/// Abstract timer background/foreground service.
///
/// For Android 14+ strict background limits; implementations (e.g. [flutter_foreground_task]) keep ~200ms tick when screen is off.
abstract class TimerBackgroundService {
  /// Start the background/foreground service (e.g. foreground notification and keep-alive).
  Future<void> startService();

  /// Stop the service and release resources.
  Future<void> stopService();

  /// Update notification text (e.g. current phase / remaining time while running).
  Future<void> updateNotification(String title, String body);
}
