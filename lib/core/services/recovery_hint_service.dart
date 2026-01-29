import 'package:flutter/foundation.dart';

/// 当从 TimerSnapshot 恢复计时状态时，通知 UI 显示「检测到异常中断，已恢复进度」。
///
/// 控制器在 [TimerSnapshotRepository] 恢复成功后调用 [notifyRecovered]，
/// 页面监听 [recoveredNotifier] 并展示 SnackBar 后调用 [consumeRecovered]。
abstract class RecoveryHintService {
  ValueListenable<bool> get recoveredNotifier;

  void notifyRecovered();

  void consumeRecovered();
}

class RecoveryHintServiceImpl implements RecoveryHintService {
  RecoveryHintServiceImpl._();
  static final RecoveryHintServiceImpl _instance = RecoveryHintServiceImpl._();
  factory RecoveryHintServiceImpl() => _instance;

  final ValueNotifier<bool> _recovered = ValueNotifier<bool>(false);

  @override
  ValueListenable<bool> get recoveredNotifier => _recovered;

  @override
  void notifyRecovered() {
    _recovered.value = true;
  }

  @override
  void consumeRecovered() {
    _recovered.value = false;
  }
}
