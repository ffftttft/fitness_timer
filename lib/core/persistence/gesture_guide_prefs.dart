import 'package:shared_preferences/shared_preferences.dart';

const _keyGestureGuideSeen = 'gesture_guide_seen';

Future<bool> gestureGuideShouldShow() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool(_keyGestureGuideSeen) ?? false);
}

Future<void> gestureGuideMarkSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyGestureGuideSeen, true);
}
