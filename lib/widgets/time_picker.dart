import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Time picker (minutes and seconds only, for indoor workout use).
/// Dual input: slider + text field, kept in sync.
/// Overflow: seconds ≥60 are converted to minutes.
class TimePicker extends StatefulWidget {
  final int totalSeconds;
  final ValueChanged<int> onChanged;
  final String title;
  final bool showTotal; // whether to show total time on the right
  /// Localized label for total (e.g. "Total" / "总计").
  final String totalLabel;
  /// Localized label for minutes (e.g. "Min" / "分").
  final String minLabel;
  /// Localized label for seconds (e.g. "Sec" / "秒").
  final String secLabel;

  const TimePicker({
    super.key,
    required this.totalSeconds,
    required this.onChanged,
    required this.title,
    this.showTotal = true, // show total by default
    required this.totalLabel,
    required this.minLabel,
    required this.secLabel,
  });

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  int get minutes => widget.totalSeconds ~/ 60;
  int get seconds => widget.totalSeconds % 60;

  void _updateTime(int m, int s) {
    final total = m * 60 + s;
    widget.onChanged(total);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: textStyle?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                if (widget.showTotal)
                  Text(
                    '${widget.totalLabel}: ${_formatMMSS(widget.totalSeconds)}',
                    style: textStyle?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _TimeSliderWithInput(
                  label: widget.minLabel,
                  value: minutes,
                  min: 0,
                  max: 59,
                  onChanged: (m) => _updateTime(m, seconds),
                ),
                const SizedBox(height: 16),
                _TimeSliderWithInput(
                  label: widget.secLabel,
                  value: seconds,
                  min: 0,
                  max: 59,
                  onChanged: (s) => _updateTime(minutes, s),
                  allowOverflow: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMMSS(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

/// Slider with text input for time (dual input, kept in sync).
class _TimeSliderWithInput extends StatefulWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final bool allowOverflow;

  const _TimeSliderWithInput({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.allowOverflow = false,
  });

  @override
  State<_TimeSliderWithInput> createState() => _TimeSliderWithInputState();
}

class _TimeSliderWithInputState extends State<_TimeSliderWithInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // commit on focus loss
      _handleTextChange(_controller.text);
    }
  }

  @override
  void didUpdateWidget(_TimeSliderWithInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      _controller.text = widget.value.toString();
      _hasError = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChange(String text) {
    // Empty: allow blank, fill 0 on blur
    if (text.trim().isEmpty) {
      if (!_focusNode.hasFocus) {
        _controller.text = '0';
        widget.onChanged(0);
      }
      return;
    }
    
    final value = int.tryParse(text);
    if (value == null) {
      // Invalid input: restore current value
      _controller.text = widget.value.toString();
      setState(() {
        _hasError = true;
      });
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _hasError = false;
          });
        }
      });
      return;
    }
    
    // Overflow: when input ≥60 and allowed, pass through for parent to convert
    if (widget.allowOverflow && value >= 60) {
      widget.onChanged(value);
      setState(() {
        _hasError = false;
      });
      HapticFeedback.selectionClick();
    } else if (value < widget.min || value > widget.max) {
      // Out of range: clamp
      final clampedValue = value.clamp(widget.min, widget.max);
      _controller.text = clampedValue.toString();
      setState(() {
        _hasError = true;
      });
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _hasError = false;
          });
        }
      });
      widget.onChanged(clampedValue);
    } else {
      // Valid: apply immediately
      setState(() {
        _hasError = false;
      });
      widget.onChanged(value);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: textStyle,
            ),
            GestureDetector(
              onTap: () {
                _focusNode.requestFocus();
                Future.delayed(const Duration(milliseconds: 100), () {
                  _controller.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _controller.text.length,
                  );
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.value.toString(),
                      style: textStyle?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.label,
                      style: textStyle?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: widget.value.toDouble().clamp(
                  widget.min.toDouble(),
                  widget.max.toDouble(),
                ),
                min: widget.min.toDouble(),
                max: widget.max.toDouble(),
                divisions: widget.max - widget.min,
                onChanged: (v) {
                  final intValue = v.round();
                  _controller.text = intValue.toString();
                  widget.onChanged(intValue);
                  HapticFeedback.selectionClick();
                },
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: _hasError
                    ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                style: textStyle?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _hasError
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: _hasError
                          ? theme.colorScheme.error
                          : theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: _hasError
                          ? theme.colorScheme.error
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: _hasError
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (text) {
                  // Apply on change: validate and update as user types
                  _handleTextChange(text);
                },
                onSubmitted: (text) {
                  _handleTextChange(text);
                  _focusNode.unfocus();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
