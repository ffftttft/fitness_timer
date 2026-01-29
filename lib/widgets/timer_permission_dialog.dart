import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/localization/app_strings.dart';
import '../core/persistence/timer_permission_prefs.dart';

/// Before starting the timer: request notification and exact-alarm via system dialog first.
/// Only if the user denies, show the explain dialog and guide to settings.
/// Returns true if the dialog was shown and dismissed, false if not shown; caller runs start when false.
Future<bool> showTimerPermissionDialogIfNeeded(
  BuildContext context, {
  required AppStrings appStrings,
  required VoidCallback onStartAfterDismiss,
}) async {
  final shouldShow = await timerPermissionDialogShouldShow();
  if (!context.mounted || !shouldShow) return false;

  // 1. Request system permissions directly (system dialog)
  if (Platform.isAndroid) {
    final notifStatus = await Permission.notification.request();
    if (!context.mounted) return true;
    // Android 12+ exact alarm (some devices show dialog, others need settings)
    await Permission.scheduleExactAlarm.request();
    if (!context.mounted) return true;
    // If notification granted, proceed without forcing settings
    if (notifStatus.isGranted) {
      await timerPermissionDialogMarkSeen();
      onStartAfterDismiss();
      return true;
    }
  }

  // 2. User denied or not granted: show explain dialog and offer opening settings
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(appStrings.timerPermissionDialogTitle),
      content: SingleChildScrollView(
        child: Text(
          appStrings.timerPermissionDialogMessage,
          style: Theme.of(ctx).textTheme.bodyMedium,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await openAppSettings();
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
          child: Text(appStrings.openBatterySettings),
        ),
        FilledButton(
          onPressed: () async {
            await timerPermissionDialogMarkSeen();
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
              onStartAfterDismiss();
            }
          },
          child: Text(appStrings.gotIt),
        ),
      ],
    ),
  );
  return true;
}
