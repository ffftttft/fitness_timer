import 'package:flutter/services.dart';

/// Haptic feedback types.
enum HapticType {
  /// Light selection (e.g. countdown tick in last few seconds)
  selection,
  /// Success (e.g. phase change)
  success,
  /// Heavy (e.g. full workout complete)
  heavy,
  /// Medium (e.g. user actions: pause/resume/reset)
  medium,
}

/// Haptic feedback service; wraps [HapticFeedback] for injection in controllers.
/// Current implementation is synchronous; if extended to async, cancel pending in Controller dispose.
abstract class HapticService {
  void trigger(HapticType type);
}

/// Default implementation using Flutter [HapticFeedback].
class HapticServiceImpl implements HapticService {
  HapticServiceImpl._();
  static final HapticServiceImpl _instance = HapticServiceImpl._();
  factory HapticServiceImpl() => _instance;

  @override
  void trigger(HapticType type) {
    switch (type) {
      case HapticType.selection:
        HapticFeedback.selectionClick();
        break;
      case HapticType.success:
        HapticFeedback.lightImpact();
        break;
      case HapticType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticType.medium:
        HapticFeedback.mediumImpact();
        break;
    }
  }
}
