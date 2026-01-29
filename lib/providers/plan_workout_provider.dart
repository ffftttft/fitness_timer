import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../audio/tone_player.dart';
import '../core/audio/tts_service.dart';
import '../core/localization/app_language.dart';
import '../models/workout_model.dart';

class PlanWorkoutProvider extends ChangeNotifier {
  PlanWorkoutProvider({
    required this.plan,
    required AppLanguage language,
  }) : _language = language {
    _init();
  }

  final WorkoutPlan plan;
  final AppLanguage _language;

  Timer? _ticker;
  final List<WorkoutStep> _timeline = [];
  int _currentIndex = 0;
  int _remainingSeconds = 0;
  bool _running = false;
  DateTime? _phaseEndAt;
  int? _lastAnnouncedSecond;

  WorkoutStep get currentStep => _timeline[_currentIndex];
  WorkoutStep? get nextStep =>
      _currentIndex + 1 < _timeline.length ? _timeline[_currentIndex + 1] : null;

  int get currentIndex => _currentIndex;
  int get remainingSeconds => _remainingSeconds;
  bool get running => _running;

  double get progress01 {
    final total = currentStep.durationSeconds;
    if (total <= 0) return 0;
    final elapsed = (total - _remainingSeconds).clamp(0, total);
    return elapsed / total;
  }

  void _buildTimeline() {
    _timeline.clear();
    // Warm-up step for the whole plan group
    if (plan.warmupSeconds > 0) {
      _timeline.add(
        WorkoutStep(
          id: 'warmup',
          name: 'Warm-up',
          durationSeconds: plan.warmupSeconds,
          type: WorkoutStepType.rest,
        ),
      );
    }

    for (final item in plan.items) {
      final sets = item.sets.clamp(1, 999);
      final perSet = item.perSetSeconds;
      final intra = item.intraRestSeconds;
      final inter = item.interRestSeconds;

      for (var i = 0; i < sets; i++) {
        if (perSet > 0) {
          _timeline.add(
            WorkoutStep(
              id: '${item.id}_set_${i + 1}',
              name: item.name,
              durationSeconds: perSet,
              type: WorkoutStepType.work,
            ),
          );
        }
        final isLastSet = i == sets - 1;
        if (!isLastSet && intra > 0) {
        _timeline.add(
          WorkoutStep(
            id: '${item.id}_intra_${i + 1}',
            name: 'Rest',
            durationSeconds: intra,
            type: WorkoutStepType.rest,
          ),
        );
        }
      }

      if (inter > 0) {
        _timeline.add(
          WorkoutStep(
            id: '${item.id}_inter',
            name: 'Rest',
            durationSeconds: inter,
            type: WorkoutStepType.rest,
          ),
        );
      }
    }
  }

  Future<void> _init() async {
    await TtsService.instance.configure(_language);
    _buildTimeline();
    if (_timeline.isNotEmpty) {
      _setCurrentStep(0);
    }
  }

  void start() {
    if (_running || _timeline.isEmpty) return;
    _running = true;
    _ensureTicker();
    _startPhase(fromStart: _phaseEndAt == null);
    notifyListeners();
  }

  void pause() {
    if (!_running) return;
    _running = false;
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
  }

  void reset() {
    pause();
    if (_timeline.isEmpty) return;
    _setCurrentStep(0);
    notifyListeners();
  }

  void skip() {
    if (_timeline.isEmpty) return;
    _advanceStep();
    notifyListeners();
  }

  void _setCurrentStep(int index) {
    _currentIndex = index.clamp(0, _timeline.length - 1);
    _remainingSeconds = currentStep.durationSeconds.clamp(0, 24 * 60 * 60);
    _phaseEndAt = null;
    _lastAnnouncedSecond = null;
  }

  void _ensureTicker() {
    _ticker ??= Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!_running) return;
      _onTick();
    });
  }

  void _onTick() {
    final endAt = _phaseEndAt;
    if (endAt == null) return;
    final now = DateTime.now();
    final msLeft = endAt.difference(now).inMilliseconds;
    final nextRemaining = (msLeft / 1000).ceil().clamp(0, 1 << 30);

    if (nextRemaining != _remainingSeconds) {
      _remainingSeconds = nextRemaining;

      if (_remainingSeconds <= 3 &&
          _remainingSeconds >= 1 &&
          _lastAnnouncedSecond != _remainingSeconds) {
        _lastAnnouncedSecond = _remainingSeconds;
        // Short beep + TTS countdown
        TonePlayer.instance.play(AppTone.pop);
        TtsService.instance.speakCountdown(_remainingSeconds);
      }

      notifyListeners();
    }

    if (msLeft <= 0) {
      _advanceStep();
      notifyListeners();
    }
  }

  void _startPhase({required bool fromStart}) {
    if (fromStart) {
      _remainingSeconds =
          currentStep.durationSeconds.clamp(0, 24 * 60 * 60);
    }
    final duration = Duration(seconds: _remainingSeconds);
    _phaseEndAt = DateTime.now().add(duration);
    _lastAnnouncedSecond = null;

    // Phase change feedback + TTS
    if (fromStart) {
      HapticFeedback.heavyImpact();
      TtsService.instance.speakStepName(currentStep.name);
      switch (currentStep.type) {
        case WorkoutStepType.work:
          TonePlayer.instance.play(AppTone.doubleBeep);
          break;
        case WorkoutStepType.rest:
          TonePlayer.instance.play(AppTone.soft);
          break;
      }
    }
  }

  void _advanceStep() {
    _lastAnnouncedSecond = null;
    if (_currentIndex + 1 < _timeline.length) {
      _setCurrentStep(_currentIndex + 1);
      if (_running) {
        _startPhase(fromStart: true);
      }
    } else {
      // Done
      _running = false;
      _ticker?.cancel();
      _ticker = null;
      _phaseEndAt = null;
      _remainingSeconds = 0;
      TonePlayer.instance.play(AppTone.tripleBeep);
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

