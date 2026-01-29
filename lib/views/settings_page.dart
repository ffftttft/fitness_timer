import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/di/injection.dart';
import '../core/localization/app_language.dart';
import '../core/localization/app_strings.dart';
import '../core/services/health_sync_status.dart';
import '../models/workout_config.dart';
import '../models/workout_model.dart';
import '../providers/app_language_provider.dart';
import '../providers/workout_config_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late WorkoutConfig _draft;
  PlanTimeUnit _warmupUnit = PlanTimeUnit.s;
  PlanTimeUnit _workUnit = PlanTimeUnit.s;
  PlanTimeUnit _restUnit = PlanTimeUnit.s;

  @override
  void initState() {
    super.initState();
    _draft = context.read<WorkoutConfigProvider>().config;
    // Infer unit from current value (e.g. >= 60 may be minutes)
    _warmupUnit = _draft.warmupSeconds >= 60 ? PlanTimeUnit.min : PlanTimeUnit.s;
    _workUnit = _draft.workSeconds >= 60 ? PlanTimeUnit.min : PlanTimeUnit.s;
    _restUnit = _draft.restSeconds >= 60 ? PlanTimeUnit.min : PlanTimeUnit.s;
  }

  double _getValueInUnit(int seconds, PlanTimeUnit unit) {
    return unit == PlanTimeUnit.min ? (seconds / 60).toDouble() : seconds.toDouble();
  }

  int _getSecondsFromValue(int value, PlanTimeUnit unit) {
    return unit == PlanTimeUnit.min ? value * 60 : value;
  }

  Future<void> _save() async {
    await context.read<WorkoutConfigProvider>().update(_draft);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<AppLanguageProvider>();
    final lang = langProvider.language;
    final s = AppStrings.of(context, lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settingsTitle),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(s.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _sectionTitle(s.workoutParameters),
          _timeSlider(
            title: s.warmupSeconds.replaceAll('（秒）', '').replaceAll('(seconds)', ''),
            value: _getValueInUnit(_draft.warmupSeconds, _warmupUnit),
            unit: _warmupUnit,
            min: 0.0,
            max: _warmupUnit == PlanTimeUnit.min ? 10.0 : 60.0,
            divisions: _warmupUnit == PlanTimeUnit.min ? 10 : 60,
            onUnitChanged: (unit) {
              setState(() {
                final currentValue = _getValueInUnit(_draft.warmupSeconds, _warmupUnit);
                _warmupUnit = unit;
                _draft = _draft.copyWith(
                  warmupSeconds: _getSecondsFromValue(currentValue.round().toInt(), unit),
                );
              });
            },
            onChanged: (v) => setState(
              () => _draft = _draft.copyWith(
                warmupSeconds: _getSecondsFromValue(v.round().toInt(), _warmupUnit),
              ),
            ),
          ),
          _timeSlider(
            title: s.workSeconds.replaceAll('（秒）', '').replaceAll('(seconds)', ''),
            value: _getValueInUnit(_draft.workSeconds, _workUnit),
            unit: _workUnit,
            min: _workUnit == PlanTimeUnit.min ? 1 : 5,
            max: _workUnit == PlanTimeUnit.min ? 30 : 180,
            divisions: _workUnit == PlanTimeUnit.min ? 29 : 175,
            onUnitChanged: (unit) {
              setState(() {
                final currentValue = _getValueInUnit(_draft.workSeconds, _workUnit);
                _workUnit = unit;
                _draft = _draft.copyWith(
                  workSeconds: _getSecondsFromValue(currentValue.round().toInt(), unit),
                );
              });
            },
            onChanged: (v) => setState(
              () => _draft = _draft.copyWith(
                workSeconds: _getSecondsFromValue(v.round(), _workUnit),
              ),
            ),
          ),
          _timeSlider(
            title: s.restSeconds.replaceAll('（秒）', '').replaceAll('(seconds)', ''),
            value: _getValueInUnit(_draft.restSeconds, _restUnit),
            unit: _restUnit,
            min: 0.0,
            max: _restUnit == PlanTimeUnit.min ? 10.0 : 180.0,
            divisions: _restUnit == PlanTimeUnit.min ? 10 : 180,
            onUnitChanged: (unit) {
              setState(() {
                final currentValue = _getValueInUnit(_draft.restSeconds, _restUnit);
                _restUnit = unit;
                _draft = _draft.copyWith(
                  restSeconds: _getSecondsFromValue(currentValue.round().toInt(), unit),
                );
              });
            },
            onChanged: (v) => setState(
              () => _draft = _draft.copyWith(
                restSeconds: _getSecondsFromValue(v.round().toInt(), _restUnit),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _roundStepper(),
          const SizedBox(height: 18),
          _sectionTitle(s.hintsTitle),
          Text(
            s.hintsBody,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          _sectionTitle(s.languageSectionTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.languageDescription,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text(s.languageEnglish),
                        selected: lang == AppLanguage.en,
                        onSelected: (selected) {
                          if (selected) {
                            langProvider.setLanguage(AppLanguage.en);
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(s.languageChinese),
                        selected: lang == AppLanguage.zh,
                        onSelected: (selected) {
                          if (selected) {
                            langProvider.setLanguage(AppLanguage.zh);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          _sectionTitle(s.healthSyncStatusTitle),
          _HealthSyncStatusCard(s: s, lang: lang),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _timeSlider({
    required String title,
    required double value,
    required PlanTimeUnit unit,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<PlanTimeUnit> onUnitChanged,
    required ValueChanged<double> onChanged,
  }) {
    final unitText = unit == PlanTimeUnit.s ? 's' : 'min';
    final label = '${value.round()}$unitText';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('$title ($unitText)')),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    SegmentedButton<PlanTimeUnit>(
                      segments: const [
                        ButtonSegment<PlanTimeUnit>(
                          value: PlanTimeUnit.s,
                          label: Text('s'),
                        ),
                        ButtonSegment<PlanTimeUnit>(
                          value: PlanTimeUnit.min,
                          label: Text('min'),
                        ),
                      ],
                      selected: {unit},
                      onSelectionChanged: (Set<PlanTimeUnit> newSelection) {
                        if (newSelection.isNotEmpty) {
                          onUnitChanged(newSelection.first);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundStepper() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Builder(
              builder: (context) {
                final lang =
                    context.watch<AppLanguageProvider>().language;
                final s = AppStrings.of(context, lang);
                return Expanded(child: Text(s.numberOfRounds));
              },
            ),
            IconButton.filledTonal(
              onPressed: _draft.rounds <= 1
                  ? null
                  : () => setState(
                        () => _draft = _draft.copyWith(rounds: _draft.rounds - 1),
                      ),
              icon: const Icon(Icons.remove),
              tooltip: 'Decrease',
            ),
            const SizedBox(width: 10),
            Text(
              '${_draft.rounds}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              onPressed: () => setState(
                () => _draft = _draft.copyWith(rounds: _draft.rounds + 1),
              ),
              icon: const Icon(Icons.add),
              tooltip: 'Increase',
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthSyncStatusCard extends StatelessWidget {
  const _HealthSyncStatusCard({
    required this.s,
    required this.lang,
  });

  final AppStrings s;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final healthStatus = getIt<HealthSyncStatus>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: FutureBuilder<bool>(
          future: healthStatus.isAuthorized(),
          builder: (context, snapshot) {
            final connected = snapshot.data ?? false;
            return Row(
              children: [
                Icon(
                  connected ? Icons.check_circle : Icons.help_outline,
                  color: connected
                      ? Colors.green
                      : Theme.of(context).colorScheme.outline,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    connected ? s.healthSyncConnected : s.healthSyncNotConnected,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (!connected)
                  FilledButton.tonal(
                    onPressed: () async {
                      await healthStatus.requestAuthorization();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              lang == AppLanguage.en
                                  ? 'Authorization requested. Check system settings if needed.'
                                  : '已请求授权，如需请到系统设置中开启。',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Text(s.healthSyncRequestAuth),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}