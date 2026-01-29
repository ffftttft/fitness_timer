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
      // 确保音频 Session 已正确配置（duckOthers 等）
      await AudioSessionService.instance.ensureConfigured();
      await _tts.setSpeechRate(0.9);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _initialized = true;
    }
    await _tts.setLanguage(
      _language == AppLanguage.en ? 'en-US' : 'zh-CN',
    );
  }

  /// 播报步骤名（只播报名称，不加前缀）
  Future<void> speakStepName(String stepName) async {
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(stepName);
  }

  /// 播报：开始步骤（仅加“开始/Start”，不说阶段号）
  Future<void> speakStartStep(String stepName) async {
    final text = _language == AppLanguage.en ? 'Start $stepName' : '开始$stepName';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// 播报：继续步骤（用于组内休息结束后）
  Future<void> speakContinueStep(String stepName) async {
    final text = _language == AppLanguage.en ? 'Continue $stepName' : '继续$stepName';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// 播报：准备开始训练
  Future<void> speakGetReady() async {
    final text = _language == AppLanguage.en
        ? 'Get ready to start!'
        : '准备开始训练';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// 播报：休息一下
  Future<void> speakRest() async {
    final text = _language == AppLanguage.en
        ? 'Take a rest'
        : '休息一下';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// 播报：步骤结束 + 休息一下（用于步骤切换的休息）
  Future<void> speakStepFinishedThenRest(String stepName) async {
    final text = _language == AppLanguage.en
        ? '$stepName finished. Take a rest.'
        : '$stepName结束，休息一下';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// 播报：休息结束 + 开始/继续步骤
  Future<void> speakRestOverThenStep(String stepName, {required bool isContinue}) async {
    final action = isContinue
        ? (_language == AppLanguage.en ? 'Continue ' : '继续')
        : (_language == AppLanguage.en ? 'Start ' : '开始');
    final prefix = _language == AppLanguage.en ? 'Rest is over. ' : '休息结束，';
    final text = '$prefix$action$stepName';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text);
  }

  /// 播报：训练结束（已保存）+ 鼓励
  Future<void> speakWorkoutFinishedSaved() async {
    final text = _language == AppLanguage.en
        ? 'Workout finished. Results saved. Keep it up.'
        : '训练结束，训练结果已保存，继续加油。';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> speakCountdown(int second) async {
    final text = _language == AppLanguage.en ? '$second' : '$second';
    await AudioSessionService.instance.prepareForPlayback();
    await _tts.stop();
    await _tts.speak(text);
  }
}

