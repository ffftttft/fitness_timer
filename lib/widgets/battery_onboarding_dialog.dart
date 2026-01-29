import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/localization/app_strings.dart';
import '../core/persistence/battery_onboarding_prefs.dart';

/// On first detection of missing "ignore battery optimization" permission, show a one-time Material 3 onboarding dialog;
/// explains why the permission is needed (to avoid the system killing the timer in background) and offers a link to system settings.
Future<void> showBatteryOnboardingDialogIfNeeded(
  BuildContext context, {
  required AppStrings appStrings,
}) async {
  if (!Platform.isAndroid) return;
  final status = await Permission.ignoreBatteryOptimizations.status;
  if (status.isGranted) return;
  final shouldShow = await batteryOnboardingShouldShow();
  if (!context.mounted || !shouldShow) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.battery_charging_full, size: 48, color: Theme.of(ctx).colorScheme.primary),
      title: Text(appStrings.batteryOnboardingTitle),
      content: SingleChildScrollView(
        child: Text(
          appStrings.batteryOnboardingMessage,
          style: Theme.of(ctx).textTheme.bodyLarge,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await batteryOnboardingMarkSeen();
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
          child: Text(appStrings.gotIt),
        ),
        FilledButton.icon(
          onPressed: () async {
            await batteryOnboardingMarkSeen();
            await openAppSettings();
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
          icon: const Icon(Icons.settings),
          label: Text(appStrings.openBatterySettings),
        ),
      ],
    ),
  );
}
