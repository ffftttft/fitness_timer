import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class BigTimeText extends StatelessWidget {
  final String text;
  final Color color;

  const BigTimeText({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(anim),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      child: Text(
        text,
        key: ValueKey(text),
        style: AppTheme.timerDigitsStyle(color),
      ),
    );
  }
}

