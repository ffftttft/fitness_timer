import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

enum AppTone {
  soft,
  pop,
  doubleBeep,
  tripleBeep,
}

class TonePlayer {
  TonePlayer._();

  static final TonePlayer instance = TonePlayer._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> play(AppTone tone) async {
    final wav = _buildToneWav(tone);
    // BytesSource: 离线、无资源文件依赖，保证有声音（播放器可用时）
    await _player.stop();
    await _player.play(BytesSource(wav), volume: 1.0);
  }

  Uint8List _buildToneWav(AppTone tone) {
    // 16-bit PCM, mono
    const sampleRate = 44100;

    List<_Beep> pattern;
    switch (tone) {
      case AppTone.soft:
        pattern = const [
          _Beep(freqHz: 660, ms: 80, gapMs: 0),
        ];
        break;
      case AppTone.pop:
        pattern = const [
          _Beep(freqHz: 880, ms: 60, gapMs: 0),
        ];
        break;
      case AppTone.doubleBeep:
        pattern = const [
          _Beep(freqHz: 740, ms: 70, gapMs: 60),
          _Beep(freqHz: 740, ms: 70, gapMs: 0),
        ];
        break;
      case AppTone.tripleBeep:
        pattern = const [
          _Beep(freqHz: 880, ms: 60, gapMs: 50),
          _Beep(freqHz: 880, ms: 60, gapMs: 50),
          _Beep(freqHz: 988, ms: 70, gapMs: 0),
        ];
        break;
    }

    final samples = <int>[];
    for (final b in pattern) {
      samples.addAll(_sineSamples(
        sampleRate: sampleRate,
        freqHz: b.freqHz,
        ms: b.ms,
      ));
      if (b.gapMs > 0) {
        samples.addAll(List<int>.filled(
          (sampleRate * b.gapMs / 1000).round(),
          0,
        ));
      }
    }

    return _encodeWavPcm16Mono(
      sampleRate: sampleRate,
      samples: samples,
    );
  }

  List<int> _sineSamples({
    required int sampleRate,
    required int freqHz,
    required int ms,
  }) {
    final n = max(1, (sampleRate * ms / 1000).round());
    // 轻量“消息提示”风格：短促、不过载。振幅设置为 0.25
    const amp = 0.25;
    final out = List<int>.filled(n, 0);
    for (var i = 0; i < n; i++) {
      final t = i / sampleRate;
      // 简单淡入淡出，减少爆音
      final fade = min(1.0, min(i / (n * 0.08), (n - 1 - i) / (n * 0.08)));
      final v = sin(2 * pi * freqHz * t) * amp * fade;
      out[i] = (v * 32767).round().clamp(-32768, 32767);
    }
    return out;
  }

  Uint8List _encodeWavPcm16Mono({
    required int sampleRate,
    required List<int> samples,
  }) {
    final byteRate = sampleRate * 2; // 16-bit mono
    final blockAlign = 2;
    final dataSize = samples.length * 2;
    final riffSize = 36 + dataSize;

    final b = BytesBuilder();
    void writeAscii(String s) => b.add(Uint8List.fromList(s.codeUnits));
    void writeU32(int v) {
      final bd = ByteData(4)..setUint32(0, v, Endian.little);
      b.add(bd.buffer.asUint8List());
    }

    void writeU16(int v) {
      final bd = ByteData(2)..setUint16(0, v, Endian.little);
      b.add(bd.buffer.asUint8List());
    }

    writeAscii('RIFF');
    writeU32(riffSize);
    writeAscii('WAVE');

    writeAscii('fmt ');
    writeU32(16); // PCM
    writeU16(1); // audio format PCM
    writeU16(1); // channels
    writeU32(sampleRate);
    writeU32(byteRate);
    writeU16(blockAlign);
    writeU16(16); // bits per sample

    writeAscii('data');
    writeU32(dataSize);

    final pcm = ByteData(dataSize);
    for (var i = 0; i < samples.length; i++) {
      pcm.setInt16(i * 2, samples[i], Endian.little);
    }
    b.add(pcm.buffer.asUint8List());

    return b.toBytes();
  }
}

class _Beep {
  final int freqHz;
  final int ms;
  final int gapMs;
  const _Beep({required this.freqHz, required this.ms, required this.gapMs});
}

