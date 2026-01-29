import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

import '../localization/app_language.dart';
import '../services/audio_session_service.dart';

class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  AppLanguage _language = AppLanguage.en;
  bool _initialized = false;

  Future<void> configure(AppLanguage language) async {
    _language = language;
    if (!_initialized) {
      // Ensure audio session is configured (duckOthers etc.)
      await AudioSessionService.instance.ensureConfigured();
      await _tts.setSpeechRate(0.9);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      // Duck others: lower background music during TTS, do not stop it.
      if (Platform.isIOS) {
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.duckOthers],
        );
      }
      if (Platform.isAndroid) {
        await _tts.setAudioAttributesForNavigation();
      }
      _initialized = true;
    }
    await _tts.setLanguage(
      _language == AppLanguage.en ? 'en-US' : 'zh-CN',
    );
  }

  /// Speak step name only (no prefix).
  Future<void> speakStepName(String stepName) async {
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(stepName, focus: false);
  }

  /// Speak "Start <step name>" (no phase number).
  Future<void> speakStartStep(String stepName) async {
    final text = _language == AppLanguage.en ? 'Start $stepName' : '开始$stepName';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text, focus: false);
  }

  /// Speak "Continue <step name>" (after intra-set rest).
  Future<void> speakContinueStep(String stepName) async {
    final text = _language == AppLanguage.en ? 'Continue $stepName' : '继续$stepName';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text, focus: false);
  }

  /// Speak "Get ready to start".
  Future<void> speakGetReady() async {
    final text = _language == AppLanguage.en
        ? 'Get ready to start!'
        : '准备开始训练';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text, focus: false);
  }

  /// Speak "Take a rest".
  Future<void> speakRest() async {
    final text = _language == AppLanguage.en
        ? 'Take a rest'
        : '休息一下';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text, focus: false);
  }

  /// Speak "<step> finished, take a rest" (for step-to-step rest).
  Future<void> speakStepFinishedThenRest(String stepName) async {
    final text = _language == AppLanguage.en
        ? '$stepName finished. Take a rest.'
        : '$stepName结束，休息一下';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text, focus: false);
  }

  /// Speak "Rest over, start/continue <step>".
  Future<void> speakRestOverThenStep(String stepName, {required bool isContinue}) async {
    final action = isContinue
        ? (_language == AppLanguage.en ? 'Continue ' : '继续')
        : (_language == AppLanguage.en ? 'Start ' : '开始');
    final prefix = _language == AppLanguage.en ? 'Rest is over. ' : '休息结束，';
    final text = '$prefix$action$stepName';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text, focus: false);
  }

  /// Speak "Workout finished, results saved, keep it up".
  Future<void> speakWorkoutFinishedSaved() async {
    final text = _language == AppLanguage.en
        ? 'Workout finished. Results saved. Keep it up.'
        : '训练结束，训练结果已保存，继续加油。';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text, focus: false);
  }

  Future<void> speakCountdown(int second) async {
    final text = _language == AppLanguage.en ? '$second' : '$second';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text, focus: false);
  }
}

