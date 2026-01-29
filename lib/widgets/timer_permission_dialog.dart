import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/localization/app_strings.dart';
import '../core/persistence/timer_permission_prefs.dart';

/// 首次启动计时器时展示的权限与电池优化说明弹窗；返回 true 表示已展示并已由用户关闭，false 表示未展示（已见过），调用方在 false 时执行 start。
Future<bool> showTimerPermissionDialogIfNeeded(
  BuildContext context, {
  required AppStrings appStrings,
  required VoidCallback onStartAfterDismiss,
}) async {
  final shouldShow = await timerPermissionDialogShouldShow();
  if (!context.mounted || !shouldShow) return false;

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
