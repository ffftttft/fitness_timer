import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/app_colors.dart';
import '../core/di/injection.dart';
import '../core/localization/app_strings.dart';
import '../core/services/haptic_service.dart';
import '../core/utils/time_format.dart';
import '../domain/timer/interval_engine.dart';
import '../presentation/timer/simple_timer_controller.dart';
import '../providers/app_language_provider.dart';
import '../providers/workout_config_provider.dart';
import '../widgets/big_time_text.dart';
import '../widgets/circular_ring_progress.dart';
import '../widgets/recovery_snackbar_gate.dart';
import '../widgets/timer_controls.dart';
import '../widgets/timer_permission_dialog.dart';
import '../widgets/workout_complete_lottie.dart';

class TimerPage extends ConsumerWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = context.watch<AppLanguageProvider>().language;
    final s = AppStrings.of(context, lang);
    final cfg = context.watch<WorkoutConfigProvider>().config;

    final timerState = ref.watch(simpleTimerControllerProvider(cfg));
    final controller = ref.read(simpleTimerControllerProvider(cfg).notifier);

    // Keep screen on only while running
    if (timerState.status == TimerStatus.running) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }

    final phaseColor = _phaseColor(timerState);
    final bg = Color.lerp(AppColors.background, phaseColor, 0.12)!;

    final mmss = formatMMSS(timerState.remaining.inSeconds);

    return Scaffold(
      body: RecoverySnackBarGate(
        message: s.recoveryHintMessage,
        child: Semantics(
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
              curve: Curves.easeOut,
              color: bg,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            tooltip: s.backTooltip,
                          ),
                          const Spacer(),
                          Text(
                            timerState.status == TimerStatus.finished
                                ? s.workoutCompleted
                                : s.roundProgress(1, 1),
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _phasePill(_phaseLabel(timerState), phaseColor),
                      const SizedBox(height: 18),
                      Expanded(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Semantics(
                                label: s.progressLabel,
                                value: '${(_progress01(timerState) * 100).round()}%',
                                liveRegion: true,
                                child: CircularRingProgress(
                                  progress01: _progress01(timerState),
                                  color: phaseColor,
                                  stroke: 12,
                                  size: 290,
                                ),
                              ),
                              Semantics(
                                label: s.remainingTimeLabel(mmss),
                                value: mmss,
                                liveRegion: true,
                                child: BigTimeText(
                                  text: mmss,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (timerState.status == TimerStatus.finished)
                                const WorkoutCompleteLottie(size: 140),
                            ],
                          ),
                        ),
                      ),
                      TimerControls(
                        running: timerState.status == TimerStatus.running,
                        onStartPause: () async {
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
                      ),
                      const SizedBox(height: 12),
                      Text(
                        timerState.status == TimerStatus.running
                            ? s.timerHintRunning
                            : s.timerHintIdle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _progress01(TimerState state) {
    if (state.total <= Duration.zero) return 0;
    final value =
        state.elapsed.inMilliseconds / state.total.inMilliseconds.clamp(1, 1 << 31);
    return value.clamp(0, 1).toDouble();
  }

  String _phaseLabel(TimerState state) {
    if (state.intervals.isEmpty || state.isFinished) {
      return 'Done';
    }
    final interval = state.intervals[state.currentIntervalIndex];
    switch (interval.type) {
      case IntervalType.warmup:
        return 'Warm-up';
      case IntervalType.work:
        return 'Work';
      case IntervalType.rest:
        return 'Rest';
      case IntervalType.cooldown:
        return 'Cooldown';
    }
  }

  Color _phaseColor(TimerState state) {
    if (state.intervals.isEmpty) {
      return Colors.white;
    }
    final interval = state.intervals[state.currentIntervalIndex];
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

  Widget _phasePill(String text, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

