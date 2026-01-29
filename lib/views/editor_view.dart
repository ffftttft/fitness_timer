import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/localization/app_language.dart';
import '../core/localization/app_strings.dart';
import '../models/workout_model.dart';
import '../providers/app_language_provider.dart';
import '../providers/workout_plan_provider.dart';
import '../widgets/time_picker.dart';

class EditorView extends StatefulWidget {
  final WorkoutPlan? existingPlan;

  const EditorView({super.key, required this.existingPlan});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late FocusNode _titleFocusNode;
  late FocusNode _descFocusNode;
  late List<PlanItem> _items;
  int _warmupSeconds = 0;

  @override
  void initState() {
    super.initState();
    final plan = widget.existingPlan;
    _titleController = TextEditingController(text: plan?.title ?? '');
    _descController = TextEditingController(text: plan?.description ?? '');
    _titleFocusNode = FocusNode();
    _descFocusNode = FocusNode();
    _titleFocusNode.addListener(_onTitleFocusChange);
    _descFocusNode.addListener(_onDescFocusChange);
    _warmupSeconds = plan?.warmupSeconds ?? 30;
    _items = List<PlanItem>.from(plan?.items ?? const []);
  }

  void _onTitleFocusChange() {
    if (!_titleFocusNode.hasFocus) {
      final t = _titleController.text.trim();
      if (t != _titleController.text) {
        _titleController.text = t;
        _titleController.selection = TextSelection.collapsed(offset: t.length);
        setState(() {});
      }
    }
  }

  void _onDescFocusChange() {
    if (!_descFocusNode.hasFocus) {
      final t = _descController.text.trim();
      if (t != _descController.text) {
        _descController.text = t;
        _descController.selection = TextSelection.collapsed(offset: t.length);
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _titleFocusNode.removeListener(_onTitleFocusChange);
    _descFocusNode.removeListener(_onDescFocusChange);
    _titleFocusNode.dispose();
    _descFocusNode.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Whether there are unsaved changes.
  bool _checkForUnsavedChanges() {
    if (_titleController.text.trim() != (widget.existingPlan?.title ?? '')) {
      return true;
    }
    if (_descController.text.trim() != (widget.existingPlan?.description ?? '')) {
      return true;
    }
    if (_warmupSeconds != (widget.existingPlan?.warmupSeconds ?? 0)) {
      return true;
    }
    if (widget.existingPlan != null) {
      if (_items.length != widget.existingPlan!.items.length) {
        return true;
      }
      for (int i = 0; i < _items.length; i++) {
        if (i >= widget.existingPlan!.items.length) return true;
        
        final originalItem = widget.existingPlan!.items[i];
        final currentItem = _items[i];
        
        if (originalItem.id != currentItem.id ||
            originalItem.name != currentItem.name ||
            originalItem.sets != currentItem.sets ||
            originalItem.perSetSeconds != currentItem.perSetSeconds ||
            originalItem.intraRestSeconds != currentItem.intraRestSeconds ||
            originalItem.interRestSeconds != currentItem.interRestSeconds) {
          return true;
        }
      }
    } else {
      if (_items.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  Future<void> _save() async {
    HapticFeedback.mediumImpact();
    
    final lang = context.read<AppLanguageProvider>().language;
    final s = AppStrings.of(context, lang);
    final provider = context.read<WorkoutPlanProvider>();
    final now = DateTime.now();
    final base = widget.existingPlan;
    final title = _titleController.text.trim();
    
    String? errorTitle;
    String? errorMessage;
    
    if (title.isEmpty) {
      errorTitle = '标题不能为空';
      errorMessage = '请输入计划标题';
    } else {
      final duplicatePlan = provider.plans.any(
        (p) => p.title == title && p.id != (base?.id ?? ''),
      );
      if (duplicatePlan) {
        errorTitle = '计划标题重复';
        errorMessage = '已存在同名计划组"$title"，请使用其他标题';
      }
    }
    
    if (errorTitle == null && _items.isNotEmpty) {
      final totalDuration = _warmupSeconds +
          _items.fold<int>(0, (sum, item) {
            final workTotal = item.perSetSeconds * item.sets;
            final intraTotal = item.sets > 1 ? item.intraRestSeconds * (item.sets - 1) : 0;
            return sum + workTotal + intraTotal + item.interRestSeconds;
          });
      if (totalDuration <= 0) {
        errorTitle = '总时长无效';
        errorMessage = '计划的总时长必须大于 0';
      } else {
        for (var i = 0; i < _items.length; i++) {
          final item = _items[i];
          if (item.sets < 1 || item.sets > 20) {
            errorTitle = '组数设置异常';
            errorMessage = '步骤 "${item.name}" 的组数必须在 1-20 之间，当前为 ${item.sets}';
            break;
          }
          if (item.perSetSeconds <= 0) {
            errorTitle = '持续时间设置异常';
            errorMessage = '步骤 "${item.name}" 的持续时间必须大于 0 秒';
            break;
          }
          if (item.sets > 1 && item.intraRestSeconds == 0) {
            errorTitle = '组内休息时间设置异常';
            errorMessage = '步骤 "${item.name}" 的组数大于 1，组内休息时间不能为 0';
            break;
          }
        }
      }
    }
    
    if (errorTitle != null) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(errorTitle!),
          content: Text(errorMessage ?? ''),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
      return;
    }
    
    final plan = WorkoutPlan(
      id: base?.id ?? UniqueKey().toString(),
      title: title,
      description: _descController.text.trim(),
      warmupSeconds: _warmupSeconds.clamp(0, 24 * 60 * 60),
      items: List.unmodifiable(_items),
      createdAt: base?.createdAt ?? now,
      updatedAt: now,
    );
    await provider.addOrUpdate(plan);
    if (mounted) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.save),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _addStepDialog({PlanItem? existingItem, int? editIndex}) {
    HapticFeedback.lightImpact();
    
    final lang = context.read<AppLanguageProvider>().language;
    final s = AppStrings.of(context, lang);
    final nameController = TextEditingController(text: existingItem?.name ?? '');
    final setsController = TextEditingController(text: (existingItem?.sets ?? 1).toString());
    int perSetSeconds = existingItem?.perSetSeconds ?? 60;
    int intraRestSeconds = existingItem?.intraRestSeconds ?? 60;
    int interRestSeconds = existingItem?.interRestSeconds ?? 60;
    final initialName = existingItem?.name ?? '';
    final initialSets = existingItem?.sets ?? 1;
    final initialPerSetSeconds = perSetSeconds;
    final initialIntraRestSeconds = intraRestSeconds;
    final initialInterRestSeconds = interRestSeconds;

    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentSets = int.tryParse(setsController.text.trim()) ?? 1;
            final showIntraRest = currentSets > 1; // show intra-set rest only when sets > 1

            bool hasUnsavedChanges() {
              final name = nameController.text.trim();
              final sets = int.tryParse(setsController.text.trim()) ?? 1;
              final effectiveIntra = sets > 1 ? intraRestSeconds : 0;
              final initialEffectiveIntra = initialSets > 1 ? initialIntraRestSeconds : 0;
              return name != initialName ||
                  sets != initialSets ||
                  perSetSeconds != initialPerSetSeconds ||
                  effectiveIntra != initialEffectiveIntra ||
                  interRestSeconds != initialInterRestSeconds;
            }

            Future<bool> confirmDiscardIfNeeded() async {
              if (!hasUnsavedChanges()) return true;
              final shouldDiscard = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(lang == AppLanguage.en ? 'Unsaved changes' : '未保存更改'),
                      content: Text(
                        lang == AppLanguage.en
                            ? 'You have unsaved changes. Do you want to discard them?'
                            : '您有未保存的更改，是否放弃？',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(s.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(lang == AppLanguage.en ? 'Discard' : '放弃'),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              return shouldDiscard;
            }

            return WillPopScope(
              onWillPop: () async => await confirmDiscardIfNeeded(),
              child: AlertDialog(
              title: Text(existingItem == null ? s.addStep : '编辑步骤'),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: s.stepNameLabel,
                      ),
                      onChanged: (_) => HapticFeedback.selectionClick(),
                    ),
                    const SizedBox(height: 16),
                    _setsInputWithSlider(
                      controller: setsController,
                      label: s.setsLabel,
                      onChanged: () {
                        HapticFeedback.selectionClick();
                        setDialogState(() {}); // rebuild to show/hide intra-set rest
                      },
                    ),
                    const SizedBox(height: 16),
                    TimePicker(
                      title: s.stepDurationLabel.replaceAll('（秒）', '').replaceAll('(seconds)', ''),
                      totalSeconds: perSetSeconds,
                      onChanged: (seconds) {
                        setDialogState(() {
                          perSetSeconds = seconds;
                        });
                      },
                      totalLabel: s.timePickerTotal,
                      minLabel: s.timePickerMin,
                      secLabel: s.timePickerSec,
                    ),
                    if (showIntraRest)
                      const SizedBox(height: 16),
                    if (showIntraRest)
                      TimePicker(
                        title: s.restBetweenSetsLabel,
                        totalSeconds: intraRestSeconds,
                        onChanged: (seconds) {
                          setDialogState(() {
                            intraRestSeconds = seconds;
                          });
                        },
                        totalLabel: s.timePickerTotal,
                        minLabel: s.timePickerMin,
                        secLabel: s.timePickerSec,
                      ),
                    const SizedBox(height: 16),
                    TimePicker(
                      title: s.restBetweenPlansLabel,
                      totalSeconds: interRestSeconds,
                      onChanged: (seconds) {
                        setDialogState(() {
                          interRestSeconds = seconds;
                        });
                      },
                      totalLabel: s.timePickerTotal,
                      minLabel: s.timePickerMin,
                      secLabel: s.timePickerSec,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    final ok = await confirmDiscardIfNeeded();
                    if (ok && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(s.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    final name = nameController.text.trim();
                    final sets = int.tryParse(setsController.text.trim()) ?? 0;
                                    
                    String? errorTitle;
                    String? errorMessage;
                                    
                    if (name.isEmpty) {
                      errorTitle = '步骤名称不能为空';
                      errorMessage = '请输入步骤名称';
                    } else {
                      final duplicateStep = _items.asMap().entries.any(
                        (entry) => entry.value.name == name && entry.key != editIndex,
                      );
                      if (duplicateStep) {
                        errorTitle = '步骤名称重复';
                        errorMessage = '已存在同名步骤“$name”，请使用其他名称';
                      }
                    }
                                    
                    if (errorTitle == null && (sets < 1 || sets > 20)) {
                      errorTitle = '组数设置异常';
                      errorMessage = '组数必须在 1-20 之间，当前为 $sets';
                    } else if (perSetSeconds <= 0) {
                      errorTitle = '持续时间设置异常';
                      errorMessage = '持续时间应该大于 0 秒';
                    }
                    if (sets == 1) {
                      intraRestSeconds = 0;
                    }
                                    
                    if (errorTitle != null) {
                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(errorTitle!),
                          content: Text(errorMessage ?? ''),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                HapticFeedback.lightImpact();
                              },
                              child: const Text('确定'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    setState(() {
                      final newItem = PlanItem(
                        id: existingItem?.id ?? UniqueKey().toString(),
                        name: name,
                        sets: sets.clamp(1, 20),
                        perSetValue: perSetSeconds,
                        perSetUnit: PlanTimeUnit.s,
                        intraRestValue: intraRestSeconds,
                        intraRestUnit: PlanTimeUnit.s,
                        interRestValue: interRestSeconds,
                        interRestUnit: PlanTimeUnit.s,
                      );
                                      
                      if (existingItem != null && editIndex != null && editIndex >= 0 && editIndex < _items.length) {
                        _items[editIndex] = newItem;
                      } else {
                        _items.add(newItem);
                      }
                    });
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                  },
                  child: Text(existingItem == null ? s.addStep : '确认修改'),
                ),
              ],
            ),
            );
          },
        );
      },
    );
  }

  Widget _setsInputWithSlider({
    required TextEditingController controller,
    required String label,
    required VoidCallback onChanged,
  }) {
    return _SetsInputWithSliderWidget(
      controller: controller,
      label: label,
      onChanged: onChanged,
    );
  }

  String _formatStepDuration(PlanItem step) {
    final seconds = step.perSetSeconds;
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatTotalTime() {
    final totalDuration = _warmupSeconds + 
        _items.fold<int>(0, (sum, item) {
          final workTotal = item.perSetSeconds * item.sets;
          final intraTotal = item.sets > 1 ? item.intraRestSeconds * (item.sets - 1) : 0;
          return sum + workTotal + intraTotal + item.interRestSeconds;
        });
    final m = totalDuration ~/ 60;
    final s = totalDuration % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppLanguageProvider>().language;
    final s = AppStrings.of(context, lang);

    return WillPopScope(
      onWillPop: () async {
        bool hasUnsavedChanges = _checkForUnsavedChanges();
        if (hasUnsavedChanges) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(lang == AppLanguage.en ? 'Unsaved changes' : '未保存更改'),
              content: Text(
                lang == AppLanguage.en
                    ? 'You have unsaved changes. Do you want to discard them?'
                    : '您有未保存的更改，是否放弃？',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(s.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text(lang == AppLanguage.en ? 'Discard' : '放弃'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.existingPlan == null ? s.createPlan : s.editPlan),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                HapticFeedback.lightImpact();
                _save();
              },
              tooltip: s.save,
            ),
            if (widget.existingPlan != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: s.deletePlan,
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  final provider = context.read<WorkoutPlanProvider>();
                  final planId = widget.existingPlan!.id;
                  final ok = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(s.deletePlan),
                          content: Text(s.deletePlanConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(s.cancel),
                            ),
                            FilledButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(context, true);
                              },
                              child: Text(s.deletePlan),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  if (!ok || !mounted) return;
                  HapticFeedback.mediumImpact();
                  await provider.deletePlan(planId);
                  if (!mounted) return;
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                decoration: InputDecoration(
                  labelText: s.planTitleLabel,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                focusNode: _descFocusNode,
                decoration: InputDecoration(
                  labelText: s.planDescriptionLabel,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TimePicker(
                title: s.warmupInputLabel.replaceAll('（秒）', '').replaceAll('(seconds)', ''),
                totalSeconds: _warmupSeconds,
                showTotal: true, // show total duration
                onChanged: (seconds) {
                  setState(() {
                    _warmupSeconds = seconds;
                  });
                },
                totalLabel: s.timePickerTotal,
                minLabel: s.timePickerMin,
                secLabel: s.timePickerSec,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      s.stepsCountLabel(_items.length),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Text(
                    s.reorderHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_items.isEmpty)
                _EmptyStepsPlaceholder(
                  onAddTap: () {
                    HapticFeedback.lightImpact();
                    _addStepDialog();
                  },
                )
              else
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  onReorder: (oldIndex, newIndex) {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = _items.removeAt(oldIndex);
                      _items.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    if (index >= _items.length) return const SizedBox.shrink();
                    final step = _items[index];
                    return Dismissible(
                    key: ValueKey(step.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      HapticFeedback.lightImpact();
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(s.deleteStep),
                          content: Text(
                            lang == AppLanguage.en
                                ? 'Are you sure you want to delete "${step.name}"?'
                                : '确定要删除步骤"${step.name}"吗？',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(s.cancel),
                            ),
                            FilledButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(context, true);
                              },
                              child: Text(s.deleteStep),
                            ),
                          ],
                        ),
                      ) ?? false;
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s.deleteStep,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onError,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (_) {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        if (index >= 0 && index < _items.length) {
                          _items.removeAt(index);
                        }
                      });
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(step.name),
                        subtitle: Text(
                          '${step.sets}组 · ${_formatStepDuration(step)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: '编辑',
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                _addStepDialog(existingItem: step, editIndex: index);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: s.deleteStep,
                              onPressed: () async {
                                HapticFeedback.lightImpact();
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(s.deleteStep),
                                    content: Text(
                                      lang == AppLanguage.en
                                          ? 'Are you sure you want to delete "${step.name}"?'
                                          : '确定要删除步骤"${step.name}"吗？',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text(s.cancel),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          HapticFeedback.mediumImpact();
                                          Navigator.pop(context, true);
                                        },
                                        child: Text(s.deleteStep),
                                      ),
                                    ],
                                  ),
                                ) ?? false;
                                    
                                if (confirmed) {
                                  HapticFeedback.mediumImpact();
                                  setState(() {
                                    if (index >= 0 && index < _items.length) {
                                      _items.removeAt(index);
                                    }
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 4),
                            ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_handle,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _addStepDialog(existingItem: step, editIndex: index);
                        },
                      ),
                    ),
                  );
                  },
                ),
            ],
          ),
        ),
        bottomSheet: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _addStepDialog();
              },
              icon: const Icon(Icons.add),
              label: Text(s.addStep),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetsInputWithSliderWidget extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onChanged;

  const _SetsInputWithSliderWidget({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  @override
  State<_SetsInputWithSliderWidget> createState() => _SetsInputWithSliderWidgetState();
}

class _SetsInputWithSliderWidgetState extends State<_SetsInputWithSliderWidget> {
  late FocusNode _focusNode;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _handleTextChange(widget.controller.text);
    }
  }

  void _handleTextChange(String text) {
    final value = int.tryParse(text);
    final currentSets = int.tryParse(widget.controller.text.trim()) ?? 1;
    final clampedSets = currentSets.clamp(1, 20);
    
    if (value == null || value < 1 || value > 20) {
      final clamped = (value ?? clampedSets).clamp(1, 20);
      widget.controller.text = clamped.toString();
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
      widget.onChanged();
    } else {
      setState(() {
        _hasError = false;
      });
      widget.onChanged();
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sets = int.tryParse(widget.controller.text.trim()) ?? 1;
    final clampedSets = sets.clamp(1, 20);
    
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                GestureDetector(
                  onTap: () {
                    _focusNode.requestFocus();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      widget.controller.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: widget.controller.text.length,
                      );
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          clampedSets.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '组',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                    value: clampedSets.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    onChanged: (v) {
                      final intValue = v.round();
                      widget.controller.text = intValue.toString();
                      setState(() {});
                      widget.onChanged();
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
                        ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _hasError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurface,
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
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                          color: _hasError
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(
                          color: _hasError
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (text) {
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

class _EmptyStepsPlaceholder extends StatefulWidget {
  final VoidCallback onAddTap;

  const _EmptyStepsPlaceholder({required this.onAddTap});

  @override
  State<_EmptyStepsPlaceholder> createState() => _EmptyStepsPlaceholderState();
}

class _EmptyStepsPlaceholderState extends State<_EmptyStepsPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: secondaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无步骤',
            style: theme.textTheme.titleMedium?.copyWith(
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加第一个步骤',
            style: theme.textTheme.bodySmall?.copyWith(
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animation.value),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 32,
                  color: primaryColor.withValues(alpha: 0.6),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


