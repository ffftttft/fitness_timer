import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../core/services/recovery_hint_service.dart';

/// 监听 [RecoveryHintService]，当从 TimerSnapshot 恢复时显示 SnackBar「检测到异常中断，已恢复进度」。
class RecoverySnackBarGate extends StatefulWidget {
  const RecoverySnackBarGate({
    super.key,
    required this.message,
    required this.child,
  });

  final String message;
  final Widget child;

  @override
  State<RecoverySnackBarGate> createState() => _RecoverySnackBarGateState();
}

class _RecoverySnackBarGateState extends State<RecoverySnackBarGate> {
  @override
  void initState() {
    super.initState();
    getIt<RecoveryHintService>().recoveredNotifier.addListener(_onRecovered);
  }

  @override
  void dispose() {
    getIt<RecoveryHintService>().recoveredNotifier.removeListener(_onRecovered);
    super.dispose();
  }

  void _onRecovered() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.message),
        behavior: SnackBarBehavior.floating,
      ),
    );
    getIt<RecoveryHintService>().consumeRecovered();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
