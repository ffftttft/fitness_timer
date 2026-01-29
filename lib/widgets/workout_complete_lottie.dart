import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// 训练完成时展示的 Lottie 奖励动画（打卡成功/完成）。
///
/// 资源缺失时回退为图标，避免白屏。
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
