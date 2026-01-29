String formatMMSS(int totalSeconds) {
  final s = totalSeconds.clamp(0, 24 * 60 * 60);
  final m = s ~/ 60;
  final r = s % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = r.toString().padLeft(2, '0');
  return '$mm:$ss';
}

