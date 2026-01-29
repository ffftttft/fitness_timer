import 'dart:io';

import 'package:audio_session/audio_session.dart';

/// Centralized audio session config so TTS / sounds coexist with system and other apps.
///
/// Duck mode (not interrupt):
/// - iOS: playback + duckOthers so other apps are ducked, not stopped.
/// - Android: speech + gainTransientMayDuck for mixing with music/podcasts.
///
/// Call [prepareForPlayback] before playing to allow ducking transition.
/// Background volume is restored by the system after playback; no explicit release needed.
class AudioSessionService {
  AudioSessionService._();

  static final AudioSessionService instance = AudioSessionService._();

  bool _configured = false;

  static const int _duckingTransitionMs = 300;

  Future<void> ensureConfigured() async {
    if (_configured) return;
    final session = await AudioSession.instance;

    // Duck mode: lower other apps' volume, do not interrupt
    final config = AudioSessionConfiguration.speech().copyWith(
      androidAudioAttributes: const AndroidAudioAttributes(
        usage: AndroidAudioUsage.notificationRingtone,
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      androidWillPauseWhenDucked: false,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
    );

    await session.configure(config);

    if (Platform.isIOS) {
      await session.setActive(true);
    }

    _configured = true;
  }

  /// Call before TTS or sound playback to allow smooth ducking transition.
  Future<void> prepareForPlayback() async {
    await ensureConfigured();
    await Future<void>.delayed(const Duration(milliseconds: _duckingTransitionMs));
  }
}

