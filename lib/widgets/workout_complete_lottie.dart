import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Lottie completion animation shown when a workout finishes.
///
/// Falls back to an icon if the asset is missing to avoid a blank screen.
class WorkoutCompleteLottie extends StatelessWidget {
  const WorkoutCompleteLottie({
    super.key,
    this.size = 160,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/animations/success.json',
        fit: BoxFit.contain,
        repeat: false,
        errorBuilder: (_, __, ___) => Icon(
          Icons.check_circle,
          size: size,
          color: Colors.greenAccent,
        ),
      ),
    );
  }
}
