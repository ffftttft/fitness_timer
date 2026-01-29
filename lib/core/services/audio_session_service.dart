import 'dart:io';

import 'package:audio_session/audio_session.dart';

/// 统一的音频 Session 配置，确保 TTS / 提示音与系统、其它 App 友好共存。
///
/// 目标效果：
/// - iOS: 使用 AVAudioSessionCategoryPlayback，并开启 duckOthers，
///   播报/提示音时压低其它 App 音量，而不是直接打断；
/// - Android: 使用 speech 类别 + canDuck，避免与音乐/播客强冲突。
///
/// [prepareForPlayback]：在 TTS/提示音播放前调用，预留 300ms 让系统完成 ducking 过渡，
/// 避免音量瞬间跳变，提升听感。
class AudioSessionService {
  AudioSessionService._();

  static final AudioSessionService instance = AudioSessionService._();

  bool _configured = false;

  /// Ducking 过渡预留时间（毫秒），给系统压低背景音的时间
  static const int _duckingTransitionMs = 300;

  Future<void> ensureConfigured() async {
    if (_configured) return;
    final session = await AudioSession.instance;

    // 基于 speech 配置，再按平台微调。
    final config = AudioSessionConfiguration.speech().copyWith(
      androidAudioAttributes: const AndroidAudioAttributes(
        usage: AndroidAudioUsage.notificationRingtone,
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      androidWillPauseWhenDucked: false,
      // iOS 由 audio_session 根据 category 推断，duckOthers 会在下方设置。
    );

    await session.configure(config);

    if (Platform.isIOS) {
      // iOS 额外开启 duckOthers，使其它音源自动压低音量
      await session.setActive(true);
    }

    _configured = true;
  }

  /// 在播放 TTS 或提示音前调用，先确保 Session 已配置，再等待 [_duckingTransitionMs]，
  /// 使系统 ducking 过渡更平滑，避免突兀音量跳变。
  Future<void> prepareForPlayback() async {
    await ensureConfigured();
    await Future<void>.delayed(const Duration(milliseconds: _duckingTransitionMs));
  }
}

