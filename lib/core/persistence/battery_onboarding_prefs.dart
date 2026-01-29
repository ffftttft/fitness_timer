import 'package:shared_preferences/shared_preferences.dart';

const _keyBatteryOnboardingSeen = 'battery_onboarding_dialog_seen';

Future<bool> batteryOnboardingShouldShow() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_keyBatteryOnboardingSeen) ?? false);
}

Future<void> batteryOnboardingMarkSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyBatteryOnboardingSeen, true);
}
