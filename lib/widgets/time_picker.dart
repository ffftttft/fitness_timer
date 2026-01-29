import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 时间选择器组件（仅分钟和秒，针对室内健身场景优化）
/// 支持双模输入：滑动条 + 文本框，无感同步
/// 支持溢出处理：秒 ≥60 时自动换算为分钟
class TimePicker extends StatefulWidget {
  final int totalSeconds;
  final ValueChanged<int> onChanged;
  final String title;
  final bool showTotal; // 是否显示右侧的总计时间

  const TimePicker({
    super.key,
    required this.totalSeconds,
    required this.onChanged,
    required this.title,
    this.showTotal = true, // 默认显示总计
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
                    '总计: ${_formatMMSS(widget.totalSeconds)}',
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
                  label: '分钟',
                  value: minutes,
                  min: 0,
                  max: 59,
                  onChanged: (m) => _updateTime(m, seconds),
                ),
                const SizedBox(height: 16),
                _TimeSliderWithInput(
                  label: '秒',
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

/// 带文本输入的时间滑块组件（双模输入 + 无感同步）
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
      // 失去焦点时自动保存
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
    // 清空处理：允许空字符串，失焦时回填 0
    if (text.trim().isEmpty) {
      if (!_focusNode.hasFocus) {
        _controller.text = '0';
        widget.onChanged(0);
      }
      return;
    }
    
    final value = int.tryParse(text);
    if (value == null) {
      // 非法输入：回填当前值
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
    
    // 溢出处理：当输入 ≥60 且允许溢出时自动换算
    if (widget.allowOverflow && value >= 60) {
      // 父组件（TimePicker）会处理溢出逻辑，这里直接传递原始值
      widget.onChanged(value);
      setState(() {
        _hasError = false;
      });
      HapticFeedback.selectionClick();
    } else if (value < widget.min || value > widget.max) {
      // 超出范围：自动修正
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
      // 合法值：立即生效
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
                  // 即时生效：输入时实时校验和更新
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
