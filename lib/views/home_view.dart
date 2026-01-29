import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/di/injection.dart';
import '../core/localization/app_language.dart';
import '../core/localization/app_strings.dart';
import '../core/services/data_import_service.dart';
import '../core/utils/time_format.dart';
import '../providers/app_language_provider.dart';
import '../providers/workout_plan_provider.dart';
import '../widgets/battery_onboarding_gate.dart';
import '../widgets/battery_optimization_banner.dart';
import 'editor_view.dart';
import 'workout_history_view.dart';
import 'workout_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppLanguageProvider>().language;
    final s = AppStrings.of(context, lang);
    final planProvider = context.watch<WorkoutPlanProvider>();
    final plans = planProvider.plans;

    return BatteryOnboardingGate(
      appStrings: s,
      child: Scaffold(
      appBar: AppBar(
        title: Text(s.plansTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: lang == AppLanguage.en ? 'Workout history' : '训练历史',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WorkoutHistoryView(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: s.importWorkoutHistoryTooltip,
            onPressed: () async {
              final count = await getIt<DataImportService>().importFromCsvFile();
              if (!context.mounted) return;
              if (count == null) return; // cancelled
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    count == -1
                        ? s.importFailed
                        : s.importSuccess(count),
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<AppLanguage>(
            icon: const Icon(Icons.language),
            tooltip: s.languageSectionTitle,
            onSelected: (value) {
              context.read<AppLanguageProvider>().setLanguage(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: AppLanguage.en,
                child: Row(
                  children: [
                    if (lang == AppLanguage.en)
                      const Icon(Icons.check, size: 16),
                    if (lang == AppLanguage.en) const SizedBox(width: 6),
                    Text(s.languageEnglish),
                  ],
                ),
              ),
              PopupMenuItem(
                value: AppLanguage.zh,
                child: Row(
                  children: [
                    if (lang == AppLanguage.zh)
                      const Icon(Icons.check, size: 16),
                    if (lang == AppLanguage.zh) const SizedBox(width: 6),
                    Text(s.languageChinese),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BatteryOptimizationBanner(appStrings: s),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: plans.isEmpty
            ? Center(
                child: Text(
                  s.emptyPlansHint,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              )
            : ReorderableListView.builder(
                itemCount: plans.length,
                onReorder: (oldIndex, newIndex) {
                  planProvider.reorderPlans(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final total = formatMMSS(plan.totalDurationSeconds);
                  return Card(
                    key: ValueKey(plan.id),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(
                        plan.title.isEmpty ? s.untitledPlan : plan.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (plan.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2, bottom: 4),
                              child: Text(
                                plan.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          Text(
                            '${s.totalDurationLabel(total)} · ${s.stepsCountLabel(plan.stepCount)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditorView(existingPlan: plan),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            tooltip: s.startWorkout,
                            onPressed: plan.items.isEmpty
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          lang == AppLanguage.en
                                              ? 'Plan is empty. Please add at least one step first.'
                                              : '计划为空，请先添加至少一个步骤',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => WorkoutView(plan: plan),
                                      ),
                                    );
                                  },
                          ),
                          ReorderableDragStartListener(
                            index: index,
                            child: Icon(
                              Icons.drag_handle,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const EditorView(existingPlan: null),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(s.createPlan),
      ),
    ),
    );
  }
}

