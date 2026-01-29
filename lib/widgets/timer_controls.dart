import 'package:flutter/material.dart';

import '../core/localization/app_language.dart';
import '../core/localization/app_strings.dart';
import '../providers/app_language_provider.dart';
import 'package:provider/provider.dart';

class TimerControls extends StatelessWidget {
  final bool running;
  final VoidCallback onStartPause;
  final VoidCallback onReset;
  final VoidCallback onSkip;
  final Future<bool?> Function()? onFinish; // 可选：结束训练按钮

  const TimerControls({
    super.key,
    required this.running,
    required this.onStartPause,
    required this.onReset,
    required this.onSkip,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppLanguageProvider>().language;
    final s = AppStrings.of(context, lang);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 主要控制按钮：开始/暂停、重置、跳过
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onStartPause,
                icon: Icon(running ? Icons.pause : Icons.play_arrow),
                label: Text(running ? s.pause : s.start),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filledTonal(
              onPressed: onReset,
              icon: const Icon(Icons.replay),
              tooltip: s.reset,
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: onSkip,
              icon: const Icon(Icons.skip_next),
              tooltip: s.skip,
            ),
          ],
        ),
        // 结束训练按钮（仅在运行时显示）
        if (onFinish != null && running)
          OutlinedButton.icon(
            onPressed: () async {
              // 直接调用新的finish方法，它会处理所有逻辑
              await onFinish!();
            },
            icon: const Icon(Icons.stop),
            label: Text(lang == AppLanguage.en ? 'End workout' : '结束训练'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
      ],
    );
  }
}

