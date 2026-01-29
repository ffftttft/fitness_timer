import 'package:flutter/material.dart';

import '../core/localization/app_strings.dart';
import 'battery_onboarding_dialog.dart';

/// 首页挂载时检测：若用户从未授权「忽略电池优化」且未见过引导弹窗，则展示一次 Material 3 引导弹窗。
class BatteryOnboardingGate extends StatefulWidget {
  const BatteryOnboardingGate({
    super.key,
    required this.appStrings,
    required this.child,
  });

  final AppStrings appStrings;
  final Widget child;

  @override
  State<BatteryOnboardingGate> createState() => _BatteryOnboardingGateState();
}

class _BatteryOnboardingGateState extends State<BatteryOnboardingGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showBatteryOnboardingDialogIfNeeded(context, appStrings: widget.appStrings);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
