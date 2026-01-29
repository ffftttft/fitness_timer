import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/localization/app_strings.dart';
import '../providers/app_language_provider.dart';
import '../providers/workout_config_provider.dart';
import 'settings_page.dart';
import 'timer_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppLanguageProvider>().language;
    final s = AppStrings.of(context, lang);
    final cfgProvider = context.watch<WorkoutConfigProvider>();
    final cfg = cfgProvider.config;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.homeTitle),
        actions: [
          IconButton(
            tooltip: s.settingsTitle,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.lastConfig,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  _kv(s.warmup, '${cfg.warmupSeconds}s'),
                  _kv(s.work, '${cfg.workSeconds}s'),
                  _kv(s.rest, '${cfg.restSeconds}s'),
                  _kv(s.rounds, '${cfg.rounds}'),
                  if (!cfgProvider.loaded) ...[
                    const SizedBox(height: 10),
                    Text(
                      s.loadingConfig,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    )
                  ],
                ],
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TimerPage()),
                );
              },
              child: Text(s.startWorkout),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              child: Text(s.adjustParameters),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Text(v, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

