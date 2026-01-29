import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/app_colors.dart';
import '../core/di/injection.dart';
import '../core/localization/app_language.dart';
import '../core/localization/app_strings.dart';
import '../core/services/haptic_service.dart';
import '../core/utils/time_format.dart';
import '../domain/timer/interval_engine.dart';
import '../models/workout_model.dart';
import '../presentation/timer/plan_workout_controller.dart';
import '../providers/app_language_provider.dart';
import '../widgets/big_time_text.dart';
import '../widgets/circular_ring_progress.dart';
import '../widgets/recovery_snackbar_gate.dart';
import '../widgets/timer_controls.dart';
import '../widgets/gesture_guide_overlay.dart';
import '../widgets/timer_permission_dialog.dart';
import '../widgets/workout_complete_lottie.dart';

class WorkoutView extends ConsumerWidget {
  final WorkoutPlan plan;

  const WorkoutView({super.key, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = context.watch<AppLanguageProvider>().language;
    final s = AppStrings.of(context, lang);

    final args = PlanWorkoutArgs(plan: plan, language: lang);
    final timerState = ref.watch(planWorkoutControllerProvider(args));
    final controller = ref.read(planWorkoutControllerProvider(args).notifier);

    if (timerState.status == TimerStatus.running) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }

    final intervals = timerState.intervals;
    final hasIntervals = intervals.isNotEmpty;
    final currentIndex =
        hasIntervals ? timerState.currentIntervalIndex.clamp(0, intervals.length - 1) : 0;
    final current = hasIntervals ? intervals[currentIndex] : null;
    final next = hasIntervals && currentIndex + 1 < intervals.length
        ? intervals[currentIndex + 1]
        : null;

    int totalSetsForStepName(String stepName) {
      var total = 0;
      for (final it in intervals) {
        if (it.type == IntervalType.work && it.label == stepName) {
          total++;
        }
      }
      return total;
    }

    int currentSetForStepName(String stepName) {
      var count = 0;
      for (var i = 0; i <= currentIndex && i < intervals.length; i++) {
        final it = intervals[i];
        if (it.type == IntervalType.work && it.label == stepName) {
          count++;
        }
      }
      return count;
    }

    String phaseLabelForType(IntervalType type) {
      switch (type) {
        case IntervalType.warmup:
          return s.phaseWarmup;
        case IntervalType.work:
          return s.phaseWork;
        case IntervalType.rest:
          return s.phaseRest;
        case IntervalType.cooldown:
          return lang == AppLanguage.en ? 'Cooldown' : '放松';
      }
    }

    String currentTitle() {
      if (current == null) return '';
      if (current.type == IntervalType.work) {
        final name = current.label ?? '';
        final total = totalSetsForStepName(name);
        final cur = currentSetForStepName(name);
        final sep = lang == AppLanguage.en ? ': ' : '：';
        return total > 0 ? '$name$sep$cur/$total' : name;
      }
      return phaseLabelForType(current.type);
    }

    String nextTitle() {
      if (next == null) return '';
      if (next.type == IntervalType.work) {
        return next.label ?? '';
      }
      return phaseLabelForType(next.type);
    }

    final mmss =
        hasIntervals ? formatMMSS(_currentIntervalRemainingSeconds(timerState)) : '00:00';
    final color = _phaseColor(timerState);
    final bg = Color.lerp(AppColors.background, color, 0.12)!;
    final workDur = workElapsedWithin(timerState.intervals, timerState.elapsed);
    final calories = workDur.inSeconds * 7.5 / 60.0;
    final elapsedSeconds = timerState.elapsed.inSeconds;
    final caloriesText = calories.toStringAsFixed(1);
    final caloriesUnit = lang == AppLanguage.en ? 'kcal' : '千卡';

    final body = RecoverySnackBarGate(
        message: s.recoveryHintMessage,
        child: Semantics(
          button: true,
          label: timerState.status == TimerStatus.running
              ? (lang == AppLanguage.en ? 'Pause' : '暂停')
              : (lang == AppLanguage.en ? 'Start or Resume' : '开始或继续'),
          hint: s.gestureHintDoubleTapLongPress,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () {
              getIt<HapticService>().trigger(HapticType.medium);
              if (timerState.status == TimerStatus.running) {
                controller.pause();
              } else if (timerState.status == TimerStatus.paused) {
                controller.resume();
              } else {
                controller.start();
              }
            },
            onLongPress: () {
              getIt<HapticService>().trigger(HapticType.medium);
              controller.reset();
            },
            child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            color: bg,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            if (timerState.status == TimerStatus.running ||
                                timerState.status == TimerStatus.paused) {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  final lang = context.read<AppLanguageProvider>().language;
                                  final s = AppStrings.of(context, lang);
                                  return AlertDialog(
                                    title: Text(lang == AppLanguage.en ? 'Exit workout?' : '退出训练？'),
                                    content: Text(
                                      lang == AppLanguage.en
                                          ? 'Are you sure you want to exit? Progress will be lost if not saved.'
                                          : '您确定要退出吗？如果不保存，进度将会丢失。',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text(s.cancel),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text(lang == AppLanguage.en ? 'Exit' : '退出'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirmed == true && context.mounted) {
                                Navigator.pop(context);
                              }
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          tooltip: s.backTooltip,
                        ),
                        const Spacer(),
                        Text(
                          plan.title,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentTitle(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Semantics(
                              label: s.progressLabel,
                              value: '${(_stepProgress01(timerState) * 100).round()}%',
                              liveRegion: true,
                              child: CircularRingProgress(
                                progress01: _stepProgress01(timerState),
                                color: color,
                                stroke: 12,
                                size: 290,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _FlipClockChip(
                                  value: caloriesText,
                                  unit: caloriesUnit,
                                  animationKey: elapsedSeconds,
                                ),
                                const SizedBox(height: 10),
                                Transform.translate(
                                  offset: const Offset(0, 10),
                                  child: Semantics(
                                    label: s.remainingTimeLabel(mmss),
                                    value: mmss,
                                    liveRegion: true,
                                    child: BigTimeText(
                                      text: mmss,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (timerState.status == TimerStatus.finished)
                              const WorkoutCompleteLottie(size: 140),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      next == null ? s.lastStepLabel : s.nextStepLabel(nextTitle()),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    TimerControls(
                      running: timerState.status == TimerStatus.running,
                      onStartPause: () async {
                        if (plan.items.isEmpty && timerState.status == TimerStatus.ready) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                lang == AppLanguage.en
                                    ? 'Please add at least one step before starting'
                                    : '请至少添加一个步骤后再开始训练',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        
                        if (timerState.status == TimerStatus.running) {
                          controller.pause();
                        } else if (timerState.status == TimerStatus.paused) {
                          controller.resume();
                        } else {
                          final shown = await showTimerPermissionDialogIfNeeded(
                            context,
                            appStrings: s,
                            onStartAfterDismiss: () => controller.start(),
                          );
                          if (!context.mounted) return;
                          if (!shown) controller.start();
                        }
                      },
                      onReset: controller.reset,
                      onSkip: controller.skip,
                      onFinish: () async {
                        final wasRunning = timerState.status == TimerStatus.running;
                        if (wasRunning) controller.pause();
                        final shouldSave = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            final lang = context.read<AppLanguageProvider>().language;
                            final s = AppStrings.of(context, lang);
                            return AlertDialog(
                              title: Text(lang == AppLanguage.en ? 'End workout?' : '结束训练？'),
                              content: Text(
                                lang == AppLanguage.en
                                    ? 'Do you want to save this workout progress before ending?'
                                    : '您希望在结束前保存这次训练进度吗？',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(lang == AppLanguage.en ? 'No Save' : '不保存'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(lang == AppLanguage.en ? 'Save' : '保存'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, null),
                                  child: Text(s.cancel),
                                ),
                              ],
                            );
                          },
                        );
                        
                        if (shouldSave == null) {
                          if (wasRunning) controller.resume();
                          return null;
                        }
                        await controller.finishWithChoice(() async => shouldSave);
                        return shouldSave;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      );

    return Scaffold(
      body: timerState.status == TimerStatus.ready
          ? GestureGuideOverlayGate(
              appStrings: s,
              lang: lang,
              child: body,
            )
          : body,
    );
  }

  static int _currentIntervalRemainingSeconds(TimerState state) {
    if (state.intervals.isEmpty || state.isFinished) return 0;
    final intervals = state.intervals;
    final index = state.currentIntervalIndex.clamp(0, intervals.length - 1);
    final elapsed = state.elapsed;
    var acc = Duration.zero;
    for (var i = 0; i < index; i++) {
      acc += intervals[i].duration;
    }
    final current = intervals[index].duration;
    final intervalElapsed = elapsed - acc;
    final intervalRemaining = current - intervalElapsed;
    return intervalRemaining.inSeconds.clamp(0, 1 << 30);
  }

  static double _stepProgress01(TimerState state) {
    if (state.intervals.isEmpty || state.isFinished) return 0;
    final intervals = state.intervals;
    final index = state.currentIntervalIndex.clamp(0, intervals.length - 1);
    final elapsed = state.elapsed;
    var acc = Duration.zero;
    for (var i = 0; i < index; i++) {
      acc += intervals[i].duration;
    }
    final current = intervals[index].duration;
    if (current <= Duration.zero) return 0;
    final rawElapsed = elapsed - acc;
    final intervalElapsed = rawElapsed.isNegative
        ? Duration.zero
        : (rawElapsed > current ? current : rawElapsed);
    return intervalElapsed.inMilliseconds / current.inMilliseconds;
  }

  static Color _phaseColor(TimerState state) {
    if (state.intervals.isEmpty) {
      return AppColors.work;
    }
    final intervals = state.intervals;
    final index = state.currentIntervalIndex.clamp(0, intervals.length - 1);
    final interval = intervals[index];
    switch (interval.type) {
      case IntervalType.warmup:
        return AppColors.warmup;
      case IntervalType.work:
        return AppColors.work;
      case IntervalType.rest:
        return AppColors.rest;
      case IntervalType.cooldown:
        return Colors.white;
    }
  }
}

class _FlipClockChip extends StatelessWidget {
  const _FlipClockChip({
    required this.value,
    required this.unit,
    required this.animationKey,
  });

  final String value;
  final String unit;
  final int animationKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceContainerHighest;
    final fg = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _FlipText(
            // Trigger flip animation only when seconds change
            key: ValueKey(animationKey),
            text: value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: fg,
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              unit,
              style: theme.textTheme.bodySmall?.copyWith(
                color: fg.withValues(alpha: 0.70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlipText extends StatelessWidget {
  const _FlipText({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final rotate = Tween<double>(begin: math.pi / 2, end: 0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateX(rotate.value);
            return Transform(
              alignment: Alignment.center,
              transform: transform,
              child: child,
            );
          },
        );
      },
      child: Text(
        text,
        key: ValueKey(text),
        style: style,
      ),
    );
  }
}
