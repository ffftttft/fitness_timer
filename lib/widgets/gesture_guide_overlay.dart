import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/localization/app_language.dart';
import '../core/localization/app_strings.dart';
import '../core/persistence/gesture_guide_prefs.dart';

/// Semi-transparent overlay shown on first entry to the timer page with gesture hints; tap to dismiss and mark seen.
class GestureGuideOverlayGate extends StatefulWidget {
  const GestureGuideOverlayGate({
    super.key,
    required this.child,
    required this.appStrings,
    required this.lang,
  });

  final Widget child;
  final AppStrings appStrings;
  final AppLanguage lang;

  @override
  State<GestureGuideOverlayGate> createState() => _GestureGuideOverlayGateState();
}

class _GestureGuideOverlayGateState extends State<GestureGuideOverlayGate> {
  bool _showOverlay = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndShow());
  }

  Future<void> _checkAndShow() async {
    final shouldShow = await gestureGuideShouldShow();
    if (!mounted) return;
    setState(() {
      _checked = true;
      _showOverlay = shouldShow;
    });
  }

  Future<void> _dismiss() async {
    HapticFeedback.lightImpact();
    await gestureGuideMarkSeen();
    if (!mounted) return;
    setState(() => _showOverlay = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked || !_showOverlay) return widget.child;

    final isEn = widget.lang == AppLanguage.en;
    final title = isEn ? 'Gesture guide' : '手势说明';
    final doubleTap = isEn ? 'Double-tap: Pause / Resume' : '全屏双击：暂停 / 恢复';
    final longPress = isEn ? 'Long-press: Reset workout' : '全屏长按：重置训练';
    final gotIt = widget.appStrings.gotIt;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: Material(
            color: Colors.black54,
            child: SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismiss,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Card(
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _GuideRow(
                              icon: Icons.touch_app,
                              label: doubleTap,
                            ),
                            const SizedBox(height: 12),
                            _GuideRow(
                              icon: Icons.timer_off,
                              label: longPress,
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _dismiss,
                              child: Text(gotIt),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
