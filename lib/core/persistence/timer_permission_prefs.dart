import 'package:shared_preferences/shared_preferences.dart';

const _keyTimerPermissionDialogSeen = 'timer_permission_dialog_seen';

/// Whether the "timer permission and battery optimization" onboarding dialog has been shown (once per first timer start).
Future<bool> timerPermissionDialogShouldShow() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_keyTimerPermissionDialogSeen) ?? false);
}

Future<void> timerPermissionDialogMarkSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyTimerPermissionDialogSeen, true);
}
