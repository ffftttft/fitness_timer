import 'package:flutter/material.dart';

import '../core/localization/app_strings.dart';
import 'battery_onboarding_dialog.dart';

/// On mount, if the user has not granted "ignore battery optimization" and has not seen the onboarding dialog, show it once.
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
