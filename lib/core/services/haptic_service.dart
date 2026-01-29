import 'package:flutter/services.dart';

/// 触觉反馈类型
enum HapticType {
  /// 轻选（倒计时最后几秒的滴答感）
  selection,
  /// 成功（阶段切换）
  success,
  /// 重击（全计划完成）
  heavy,
  /// 中等（用户操作：暂停/恢复/重置等）
  medium,
}

/// 触觉反馈服务接口
///
/// 封装 [HapticFeedback]，便于在控制器中注入并在适当时机触发。
/// 当前实现为同步调用，无需在 dispose 时取消；若后续扩展为异步触觉 API，需在 Controller 的 dispose 中取消未完成请求。
abstract class HapticService {
  void trigger(HapticType type);
}

/// 基于 Flutter [HapticFeedback] 的默认实现
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
