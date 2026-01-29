import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/app_colors.dart';
import '../core/localization/app_strings.dart';

/// Shows a banner when battery optimization is not ignored; tap opens app settings (user can set "Don't optimize" for this app).
class BatteryOptimizationBanner extends StatelessWidget {
  const BatteryOptimizationBanner({
    super.key,
    required this.appStrings,
  });

  final AppStrings appStrings;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) return const SizedBox.shrink();
    return FutureBuilder<PermissionStatus>(
      future: Permission.ignoreBatteryOptimizations.status,
      builder: (context, snapshot) {
        final status = snapshot.data;
        if (status == null || status.isGranted) return const SizedBox.shrink();
        return Material(
          color: AppColors.work.withValues(alpha: 0.15),
          child: InkWell(
            onTap: () => openAppSettings(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.battery_charging_full,
                    color: AppColors.work,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      appStrings.batteryOptimizationHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  Text(
                    appStrings.openBatterySettings,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.work,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
