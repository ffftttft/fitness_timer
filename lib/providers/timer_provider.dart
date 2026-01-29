import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../audio/tone_player.dart';
import '../core/notifications/notification_service.dart';
import '../models/workout_config.dart';

enum WorkoutPhase { warmup, work, rest, done }

class TimerProvider extends ChangeNotifier {
  TimerProvider({required WorkoutConfig config}) : _config = config {
    _resetToConfig();
  }

  WorkoutConfig _config;
  Timer? _ticker;

  WorkoutPhase _phase = WorkoutPhase.warmup;
  int _round = 1; // 1-based round index
  bool _running = false;

  DateTime? _phaseEndAt;
  int _phaseTotalSeconds = 0;
  int _remainingSeconds = 0;

  // Avoid announcing the same second twice when tick is 200ms
  int? _lastAnnouncedSecond;

  WorkoutConfig get config => _config;
  WorkoutPhase get phase => _phase;
  int get round => _round;
  bool get running => _running;
  int get phaseTotalSeconds => _phaseTotalSeconds;
  int get remainingSeconds => _remainingSeconds;

  double get progress01 {
    if (_phaseTotalSeconds <= 0) return 0;
    final elapsed = (_phaseTotalSeconds - _remainingSeconds).clamp(0, _phaseTotalSeconds);
    return elapsed / _phaseTotalSeconds;
  }

  String get phaseLabel {
    switch (_phase) {
      case WorkoutPhase.warmup:
        return 'Warm-up';
      case WorkoutPhase.work:
        return 'Work';
      case WorkoutPhase.rest:
        return 'Rest';
      case WorkoutPhase.done:
        return 'Done';
    }
  }

  Future<void> setConfig(WorkoutConfig config) async {
    _config = config;
    if (_running) {
      // When running, do not change config mid-stream to avoid jumps; pause and reset to new config
      pause();
    }
    _resetToConfig();
    notifyListeners();
  }

  void start() {
    if (_running) return;
    _running = true;
    _ensureTicker();
    _startCurrentPhase(fromStart: _phaseEndAt == null);
    notifyListeners();
  }

  void pause() {
    if (!_running) return;
    _running = false;
    _ticker?.cancel();
    _ticker = null;
    NotificationService.cancelAll();
    notifyListeners();
  }

  void reset() {
    pause();
    _resetToConfig();
    notifyListeners();
  }

  void skip() {
    if (_phase == WorkoutPhase.done) return;
    _advancePhase();
    notifyListeners();
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

      // Short beeps in the last 3 seconds for any active phase
      if (_phase != WorkoutPhase.done &&
          _remainingSeconds <= 3 &&
          _remainingSeconds >= 1 &&
          _lastAnnouncedSecond != _remainingSeconds) {
        _lastAnnouncedSecond = _remainingSeconds;
        TonePlayer.instance.play(AppTone.pop);
      }

      notifyListeners();
    }

    if (msLeft <= 0) {
      // Catch up multiple phases if tick was delayed (e.g. background), so absolute time stays correct
      while (_phase != WorkoutPhase.done &&
          (_phaseEndAt?.isBefore(DateTime.now()) ?? false)) {
        _advancePhase();
      }
      notifyListeners();
    }
  }

  void _resetToConfig() {
    _phase = WorkoutPhase.warmup;
    _round = 1;
    _phaseEndAt = null;
    _phaseTotalSeconds = 0;
    _remainingSeconds = 0;
    _lastAnnouncedSecond = null;

    // If warmup is 0, start directly with work but keep the same state machine
    if (_config.warmupSeconds <= 0) {
      _phase = WorkoutPhase.work;
    }
    _applyPhaseDuration();
  }

  void _applyPhaseDuration() {
    _phaseTotalSeconds = _currentPhaseDurationSeconds();
    _remainingSeconds = _phaseTotalSeconds;
  }

  int _currentPhaseDurationSeconds() {
    switch (_phase) {
      case WorkoutPhase.warmup:
        return _config.warmupSeconds.clamp(0, 60 * 60);
      case WorkoutPhase.work:
        return _config.workSeconds.clamp(1, 60 * 60);
      case WorkoutPhase.rest:
        return _config.restSeconds.clamp(0, 60 * 60);
      case WorkoutPhase.done:
        return 0;
    }
  }

  void _startCurrentPhase({required bool fromStart}) {
    if (_phase == WorkoutPhase.done) return;
    if (fromStart) {
      _applyPhaseDuration();
    }

    final duration = Duration(seconds: _remainingSeconds);
    _phaseEndAt = DateTime.now().add(duration);
    _lastAnnouncedSecond = null;

    // Phase change feedback: only when entering a new phase (not when resuming)
    if (fromStart) {
      HapticFeedback.heavyImpact();
      switch (_phase) {
        case WorkoutPhase.warmup:
          TonePlayer.instance.play(AppTone.soft);
          break;
        case WorkoutPhase.work:
          TonePlayer.instance.play(AppTone.doubleBeep);
          break;
        case WorkoutPhase.rest:
          TonePlayer.instance.play(AppTone.soft);
          break;
        case WorkoutPhase.done:
          break;
      }
    }

    // Background notification: schedule only the current phase end.
    // Here we keep the notification text in English for simplicity, since
    // system notification localization can be handled separately if needed.
    NotificationService.schedulePhaseEnd(
      when: _phaseEndAt!,
      title: 'Fitness Timer',
      body: '$phaseLabel finished',
    );
  }

  void _advancePhase() {
    _lastAnnouncedSecond = null;

    if (_phase == WorkoutPhase.warmup) {
      _phase = WorkoutPhase.work;
      _applyPhaseDuration();
      _startCurrentPhase(fromStart: true);
      return;
    }

    if (_phase == WorkoutPhase.work) {
      // work -> rest (or directly to next work round if rest is zero)
      if (_config.restSeconds > 0) {
        _phase = WorkoutPhase.rest;
        _applyPhaseDuration();
        _startCurrentPhase(fromStart: true);
        return;
      }
      _nextRoundOrDone();
      return;
    }

    if (_phase == WorkoutPhase.rest) {
      _nextRoundOrDone();
      return;
    }
  }

  void _nextRoundOrDone() {
    if (_round < _config.rounds) {
      _round += 1;
      _phase = WorkoutPhase.work;
      _applyPhaseDuration();
      _startCurrentPhase(fromStart: true);
      return;
    }

    _phase = WorkoutPhase.done;
    _phaseEndAt = null;
    _phaseTotalSeconds = 0;
    _remainingSeconds = 0;
    NotificationService.cancelAll();
    TonePlayer.instance.play(AppTone.tripleBeep);
    HapticFeedback.heavyImpact();
    pause();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

