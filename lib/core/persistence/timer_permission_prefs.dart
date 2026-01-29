import 'package:shared_preferences/shared_preferences.dart';

const _keyTimerPermissionDialogSeen = 'timer_permission_dialog_seen';

/// 是否已展示过「计时器权限与电池优化」引导弹窗（仅首次启动计时时展示一次）。
Future<bool> timerPermissionDialogShouldShow() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_keyTimerPermissionDialogSeen) ?? false);
}

Future<void> timerPermissionDialogMarkSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyTimerPermissionDialogSeen, true);
}
