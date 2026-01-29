import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'audio/tone_player.dart';

void main() {
  runApp(FitnessTimerApp());
}

class FitnessTimerApp extends StatelessWidget {
  const FitnessTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '健身计时器',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ),
      home: PlanGroupListPage(),
    );
  }
}

//======================= 主界面：计划组列表 =======================
class PlanGroupListPage extends StatefulWidget {
  const PlanGroupListPage({super.key});

  @override
  State<PlanGroupListPage> createState() => _PlanGroupListPageState();
}

class _PlanGroupListPageState extends State<PlanGroupListPage> {
  List<PlanGroup> planGroups = [];
  bool _groupSelectionMode = false;
  final Set<PlanGroup> _selectedGroups = {};

  void _enterGroupSelection([PlanGroup? initial]) {
    setState(() {
      _groupSelectionMode = true;
      _selectedGroups.clear();
      if (initial != null) _selectedGroups.add(initial);
    });
  }

  void _exitGroupSelection() {
    setState(() {
      _groupSelectionMode = false;
      _selectedGroups.clear();
    });
  }

  void _toggleGroupSelected(PlanGroup g) {
    setState(() {
      if (_selectedGroups.contains(g)) {
        _selectedGroups.remove(g);
      } else {
        _selectedGroups.add(g);
      }
      if (_selectedGroups.isEmpty) _groupSelectionMode = false;
    });
  }

  void _selectAllGroups() {
    setState(() {
      _groupSelectionMode = true;
      _selectedGroups
        ..clear()
        ..addAll(planGroups);
    });
  }

  Future<void> _deleteSelectedGroups() async {
    if (_selectedGroups.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final count = _selectedGroups.length;
    final ok = await _confirmDelete(
      context: context,
      title: '批量删除计划组？',
      content: '将删除 $count 个计划组及其所有动作，无法恢复。',
      confirmText: '删除',
    );
    if (!ok) return;
    setState(() {
      planGroups.removeWhere(_selectedGroups.contains);
      _selectedGroups.clear();
      _groupSelectionMode = false;
    });
    messenger.showSnackBar(SnackBar(content: Text('已删除 $count 个计划组')));
  }

  void _togglePin(PlanGroup group) {
    setState(() {
      group.pinned = !group.pinned;
      // 置顶组始终排在前面，保持各自内部相对顺序
      final pinned = <PlanGroup>[];
      final normal = <PlanGroup>[];
      for (final g in planGroups) {
        (g.pinned ? pinned : normal).add(g);
      }
      planGroups
        ..clear()
        ..addAll(pinned)
        ..addAll(normal);
    });
  }

  Future<bool> _confirmDelete({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '删除',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_groupSelectionMode
            ? '已选择 ${_selectedGroups.length}'
            : '健身计划组'),
        leading: _groupSelectionMode
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: _exitGroupSelection,
              )
            : null,
        actions: _groupSelectionMode
            ? [
                IconButton(
                  tooltip: '全选',
                  onPressed: _selectAllGroups,
                  icon: Icon(Icons.select_all),
                ),
                IconButton(
                  tooltip: '删除',
                  onPressed: _deleteSelectedGroups,
                  icon: Icon(Icons.delete),
                ),
              ]
            : null,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: planGroups.length,
        itemBuilder: (context, index) {
          final group = planGroups[index];
          final selected = _selectedGroups.contains(group);
          return Dismissible(
            key: ObjectKey(group),
            direction: _groupSelectionMode
                ? DismissDirection.none
                : DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, color: Colors.white),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            confirmDismiss: (_) async {
              return await _confirmDelete(
                context: context,
                title: '删除计划组？',
                content: '“${group.name}”及其所有动作将被删除，无法恢复。',
              );
            },
            onDismissed: (_) {
              setState(() {
                planGroups.remove(group);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已删除计划组：“${group.name}”')),
              );
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: _groupSelectionMode
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) => _toggleGroupSelected(group),
                      )
                    : (group.pinned
                        ? Icon(Icons.push_pin, color: Colors.deepPurple)
                        : null),
                title: Text(
                  group.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${group.exercises.length} 个动作'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'pin') {
                      _togglePin(group);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(group.pinned ? '已置顶：${group.name}' : '已取消置顶：${group.name}'),
                        ),
                      );
                      return;
                    }
                    if (value == 'multiDelete') {
                      _enterGroupSelection(group);
                      return;
                    }
                    if (value == 'delete') {
                      final ok = await _confirmDelete(
                        context: context,
                        title: '删除计划组？',
                        content: '“${group.name}”及其所有动作将被删除，无法恢复。',
                      );
                      if (!ok) return;
                      setState(() {
                        planGroups.remove(group);
                      });
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已删除计划组：“${group.name}”')),
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'pin',
                      child: Row(
                        children: [
                          Icon(group.pinned ? Icons.push_pin : Icons.push_pin_outlined),
                          SizedBox(width: 8),
                          Text(group.pinned ? '取消置顶' : '置顶'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'multiDelete',
                      child: Row(
                        children: const [
                          Icon(Icons.checklist),
                          SizedBox(width: 8),
                          Text('批量选择删除'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red.shade700),
                          SizedBox(width: 8),
                          Text('删除'),
                        ],
                      ),
                    ),
                  ],
                ),
                onLongPress: () => _enterGroupSelection(group),
                onTap: () async {
                  if (_groupSelectionMode) {
                    _toggleGroupSelected(group);
                    return;
                  }
                  final result = await Navigator.push<PlanDetailResult>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlanDetailPage(planGroup: group),
                    ),
                  );
                  if (result == PlanDetailResult.deleteGroup) {
                    setState(() {
                      planGroups.remove(group);
                    });
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已删除计划组：“${group.name}”')),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final nameController = TextEditingController();
          final name = await showDialog<String>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('新建计划组'),
              content: TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: '计划组名称'),
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) => Navigator.pop(context, value),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('取消'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, nameController.text.trim()),
                  child: Text('确定'),
                ),
              ],
            ),
          );
          nameController.dispose();
          if (name != null && name.isNotEmpty) {
            setState(() {
              planGroups.add(PlanGroup(name: name, exercises: []));
            });
          }
        },
      ),
    );
  }
}

//======================= 计划组详情 =======================
enum PlanDetailResult { deleteGroup }

class PlanDetailPage extends StatefulWidget {
  final PlanGroup planGroup;
  const PlanDetailPage({super.key, required this.planGroup});

  @override
  State<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends State<PlanDetailPage> {
  bool _exerciseSelectionMode = false;
  final Set<Exercise> _selectedExercises = {};

  void _enterExerciseSelection([Exercise? initial]) {
    setState(() {
      _exerciseSelectionMode = true;
      _selectedExercises.clear();
      if (initial != null) _selectedExercises.add(initial);
    });
  }

  void _exitExerciseSelection() {
    setState(() {
      _exerciseSelectionMode = false;
      _selectedExercises.clear();
    });
  }

  void _toggleExerciseSelected(Exercise e) {
    setState(() {
      if (_selectedExercises.contains(e)) {
        _selectedExercises.remove(e);
      } else {
        _selectedExercises.add(e);
      }
      if (_selectedExercises.isEmpty) _exerciseSelectionMode = false;
    });
  }

  void _selectAllExercises() {
    setState(() {
      _exerciseSelectionMode = true;
      _selectedExercises
        ..clear()
        ..addAll(widget.planGroup.exercises);
    });
  }

  Future<void> _deleteSelectedExercises() async {
    if (_selectedExercises.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final count = _selectedExercises.length;
    final ok = await _confirmDelete(
      context: context,
      title: '批量删除动作？',
      content: '将删除 $count 个动作，无法恢复。',
      confirmText: '删除',
    );
    if (!ok) return;
    setState(() {
      widget.planGroup.exercises.removeWhere(_selectedExercises.contains);
      _selectedExercises.clear();
      _exerciseSelectionMode = false;
    });
    messenger.showSnackBar(SnackBar(content: Text('已删除 $count 个动作')));
  }

  Future<void> _deleteExerciseAt(int index) async {
    final exercise = widget.planGroup.exercises[index];
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _confirmDelete(
      context: context,
      title: '删除动作？',
      content: '将删除“${exercise.name}”，无法恢复。',
    );
    if (!ok) return;
    setState(() {
      widget.planGroup.exercises.removeAt(index);
    });
    messenger.showSnackBar(
      SnackBar(content: Text('已删除动作：“${exercise.name}”')),
    );
  }

  void _moveExercise(int index, int delta) {
    final list = widget.planGroup.exercises;
    final newIndex = index + delta;
    if (newIndex < 0 || newIndex >= list.length) return;
    setState(() {
      final item = list.removeAt(index);
      list.insert(newIndex, item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已移动：${widget.planGroup.exercises[newIndex].name}')),
    );
  }

  Future<bool> _confirmDelete({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '删除',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_exerciseSelectionMode
            ? '已选择 ${_selectedExercises.length}'
            : widget.planGroup.name),
        leading: _exerciseSelectionMode
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: _exitExerciseSelection,
              )
            : null,
        actions: [
          if (_exerciseSelectionMode) ...[
            IconButton(
              tooltip: '全选',
              onPressed: _selectAllExercises,
              icon: Icon(Icons.select_all),
            ),
            IconButton(
              tooltip: '删除',
              onPressed: _deleteSelectedExercises,
              icon: Icon(Icons.delete),
            ),
          ] else ...[
          IconButton(
            tooltip: '删除计划组',
            icon: Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await _confirmDelete(
                context: context,
                title: '删除计划组？',
                content: '“${widget.planGroup.name}”及其所有动作将被删除，无法恢复。',
              );
              if (!ok) return;
              if (!context.mounted) return;
              Navigator.pop(context, PlanDetailResult.deleteGroup);
            },
          ),
          ]
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12),
        itemCount: widget.planGroup.exercises.length,
        itemBuilder: (context, index) {
          final exercise = widget.planGroup.exercises[index];
          final selected = _selectedExercises.contains(exercise);
          return Dismissible(
            key: ObjectKey(exercise),
            direction: _exerciseSelectionMode
                ? DismissDirection.none
                : DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, color: Colors.white),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            confirmDismiss: (_) async {
              final ok = await _confirmDelete(
                context: context,
                title: '删除动作？',
                content: '将删除“${exercise.name}”，无法恢复。',
              );
              return ok;
            },
            onDismissed: (_) {
              final idx = widget.planGroup.exercises.indexOf(exercise);
              if (idx >= 0) {
                // 忽略二次确认（Dismissible 已确认）
                setState(() {
                  widget.planGroup.exercises.removeAt(idx);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已删除动作：“${exercise.name}”')),
                );
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: _exerciseSelectionMode
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) => _toggleExerciseSelected(exercise),
                      )
                    : null,
                title: Text(exercise.name, style: TextStyle(fontSize: 18)),
                subtitle: Text(
                  exercise.displaySummary,
                ),
                onLongPress: () => _enterExerciseSelection(exercise),
                onTap: () async {
                  if (_exerciseSelectionMode) {
                    _toggleExerciseSelected(exercise);
                    return;
                  }
                  final updated = await Navigator.push<Exercise>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddExercisePage(initialExercise: exercise),
                    ),
                  );
                  if (updated == null) return;
                  setState(() {
                    widget.planGroup.exercises[index] = updated;
                  });
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已更新动作：“${updated.name}”')),
                  );
                },
                trailing: PopupMenuButton<String>(
                  tooltip: '动作功能',
                  onSelected: (value) async {
                    if (value == 'multiDelete') {
                      _enterExerciseSelection(exercise);
                      return;
                    }
                    if (value == 'delete') {
                      await _deleteExerciseAt(index);
                      return;
                    }
                    if (value == 'up') {
                      _moveExercise(index, -1);
                      return;
                    }
                    if (value == 'down') {
                      _moveExercise(index, 1);
                      return;
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'multiDelete',
                      child: Row(
                        children: const [
                          Icon(Icons.checklist),
                          SizedBox(width: 8),
                          Text('批量选择删除'),
                        ],
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'up',
                      enabled: index > 0,
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_upward),
                          SizedBox(width: 8),
                          Text('上移'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'down',
                      enabled: index < widget.planGroup.exercises.length - 1,
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_downward),
                          SizedBox(width: 8),
                          Text('下移'),
                        ],
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red.shade700),
                          SizedBox(width: 8),
                          Text('删除'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "addExercise",
            child: Icon(Icons.add),
            onPressed: () async {
              final exercise = await Navigator.push<Exercise>(
                  context, MaterialPageRoute(builder: (_) => AddExercisePage()));
              if (exercise != null) {
                setState(() {
                  widget.planGroup.exercises.add(exercise);
                });
              }
            },
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "start",
            child: Icon(Icons.play_arrow),
            onPressed: () {
              if (widget.planGroup.exercises.isNotEmpty) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            TimerPage(exercises: widget.planGroup.exercises)));
              }
            },
          ),
        ],
      ),
    );
  }
}

//======================= 添加动作 =======================
class AddExercisePage extends StatefulWidget {
  final Exercise? initialExercise;
  const AddExercisePage({super.key, this.initialExercise});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _workValueController = TextEditingController();
  final _setsController = TextEditingController(text: '1');
  // 组内休息
  final _intraRestValueController = TextEditingController(text: '60');
  // 组间休息（动作与动作之间）
  final _interRestValueController = TextEditingController(text: '0');

  ExerciseWorkType _workType = ExerciseWorkType.time;
  TimeUnit _workUnit = TimeUnit.s;
  TimeUnit _intraRestUnit = TimeUnit.s;
  TimeUnit _interRestUnit = TimeUnit.s;
  int _setsPreview = 1;

  @override
  void initState() {
    super.initState();
    final e = widget.initialExercise;
    if (e != null) {
      _nameController.text = e.name;
      _workType = e.workType;
      _workUnit = e.workUnit;
      _workValueController.text = e.workValue.toString();
      _setsController.text = e.sets.toString();
      _setsPreview = e.sets;

      _intraRestValueController.text = e.intraRestValue.toString();
      _intraRestUnit = e.intraRestUnit;
      _interRestValueController.text = e.interRestValue.toString();
      _interRestUnit = e.interRestUnit;
    }

    _setsController.addListener(() {
      final n = int.tryParse(_setsController.text.trim()) ?? 1;
      if (n == _setsPreview) return;
      setState(() {
        _setsPreview = n < 1 ? 1 : n;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _workValueController.dispose();
    _setsController.dispose();
    _intraRestValueController.dispose();
    _interRestValueController.dispose();
    super.dispose();
  }

  int _toSeconds(int value, TimeUnit unit) => unit == TimeUnit.min ? value * 60 : value;

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialExercise != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? '修改动作' : '添加动作')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: '动作名称（必填）'),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '动作名称不能为空';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FormField<ExerciseWorkType>(
                        initialValue: _workType,
                        builder: (state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: '类型',
                              errorText: state.errorText,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ExerciseWorkType>(
                                isExpanded: true,
                                value: state.value,
                                items: const [
                                  DropdownMenuItem(
                                    value: ExerciseWorkType.time,
                                    child: Text('时间'),
                                  ),
                                  DropdownMenuItem(
                                    value: ExerciseWorkType.reps,
                                    child: Text('次数'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  state.didChange(v);
                                  setState(() {
                                    _workType = v;
                                    // 默认单位都是 s
                                    _workUnit = TimeUnit.s;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _workValueController,
                        decoration: InputDecoration(
                          labelText: _workType == ExerciseWorkType.time ? '时间数值' : '次数',
                          hintText: _workType == ExerciseWorkType.time ? '例如 30' : '例如 12',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null) return '请输入数字';
                          if (n <= 0) return '必须大于 0';
                          return null;
                        },
                      ),
                    ),
                    if (_workType == ExerciseWorkType.time) ...[
                      SizedBox(width: 12),
                      SizedBox(
                        width: 96,
                        child: FormField<TimeUnit>(
                          initialValue: _workUnit,
                          builder: (state) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                labelText: '单位',
                                errorText: state.errorText,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<TimeUnit>(
                                  isExpanded: true,
                                  value: state.value,
                                  items: const [
                                    DropdownMenuItem(value: TimeUnit.s, child: Text('s')),
                                    DropdownMenuItem(value: TimeUnit.min, child: Text('min')),
                                  ],
                                  onChanged: (v) {
                                    if (v == null) return;
                                    state.didChange(v);
                                    setState(() => _workUnit = v);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _setsController,
                  decoration: InputDecoration(labelText: '组数（整数，≥ 1）'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null) return '请输入整数';
                    if (n < 1) return '组数必须 ≥ 1';
                    return null;
                  },
                ),
                SizedBox(height: 12),
                if (_setsPreview > 1) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _intraRestValueController,
                          decoration: InputDecoration(labelText: '组内休息（同一动作每组之间）'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) {
                            final n = int.tryParse((v ?? '').trim());
                            if (n == null) return '请输入数字';
                            if (n < 0) return '不能为负数';
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      SizedBox(
                        width: 96,
                        child: FormField<TimeUnit>(
                          initialValue: _intraRestUnit,
                          builder: (state) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                labelText: '组内单位',
                                errorText: state.errorText,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<TimeUnit>(
                                  isExpanded: true,
                                  value: state.value,
                                  items: const [
                                    DropdownMenuItem(value: TimeUnit.s, child: Text('s')),
                                    DropdownMenuItem(value: TimeUnit.min, child: Text('min')),
                                  ],
                                  onChanged: (v) {
                                    if (v == null) return;
                                    state.didChange(v);
                                    setState(() => _intraRestUnit = v);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                ],
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _interRestValueController,
                        decoration: InputDecoration(labelText: '组间休息（不同动作之间）'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null) return '请输入数字';
                          if (n < 0) return '不能为负数';
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 96,
                      child: FormField<TimeUnit>(
                        initialValue: _interRestUnit,
                        builder: (state) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: '组间单位',
                              errorText: state.errorText,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<TimeUnit>(
                                isExpanded: true,
                                value: state.value,
                                items: const [
                                  DropdownMenuItem(value: TimeUnit.s, child: Text('s')),
                                  DropdownMenuItem(value: TimeUnit.min, child: Text('min')),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  state.didChange(v);
                                  setState(() => _interRestUnit = v);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final ok = _formKey.currentState?.validate() ?? false;
                      if (!ok) return;

                      final name = _nameController.text.trim();
                      final workValue = int.parse(_workValueController.text.trim());
                      final sets = int.parse(_setsController.text.trim());
                      final intraRestValue = int.parse(_intraRestValueController.text.trim());
                      final interRestValue = int.parse(_interRestValueController.text.trim());

                      final workSeconds =
                          _workType == ExerciseWorkType.time ? _toSeconds(workValue, _workUnit) : workValue;
                      final effectiveIntraRestValue = sets > 1 ? intraRestValue : 0;
                      final intraRestSeconds =
                          sets > 1 ? _toSeconds(intraRestValue, _intraRestUnit) : 0;
                      final interRestSeconds = _toSeconds(interRestValue, _interRestUnit);

                      final exercise = Exercise(
                        name: name,
                        workType: _workType,
                        workValue: workValue,
                        workUnit: _workUnit,
                        workSeconds: workSeconds,
                        sets: sets,
                        intraRestValue: effectiveIntraRestValue,
                        intraRestUnit: _intraRestUnit,
                        intraRestSeconds: intraRestSeconds,
                        interRestValue: interRestValue,
                        interRestUnit: _interRestUnit,
                        interRestSeconds: interRestSeconds,
                      );
                      Navigator.pop(context, exercise);
                    },
                    child: Text('保存动作'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//======================= 训练计时页面 =======================
class TimerPage extends StatefulWidget {
  final List<Exercise> exercises;
  const TimerPage({super.key, required this.exercises});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  int currentExerciseIndex = 0;
  int currentSet = 1;
  int remainingTime = 0;
  bool isRest = false;
  int _currentRestTotal = 0;
  RestKind? _restKind;
  Timer? timer;
  late AnimationController _animController;
  Timer? _bannerTimer;
  String? _hintText;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    // 首帧之后再启动，避免在 initState 中使用 ScaffoldMessenger.of(context) 报错
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      startExercise();
    });
  }

  Future<void> _playCue([RestKind? kind]) async {
    // 使用项目内生成的提示音，不依赖系统提示音
    final tone = switch (kind) {
      RestKind.intraSet => AppTone.doubleBeep,
      RestKind.betweenExercise => AppTone.tripleBeep,
      _ => AppTone.pop,
    };
    await TonePlayer.instance.play(tone);
  }

  void _showHint(String message, {Duration duration = const Duration(seconds: 2)}) {
    if (!mounted) return;
    _bannerTimer?.cancel();
    setState(() {
      _hintText = message;
    });
    _bannerTimer = Timer(duration, () {
      if (!mounted) return;
      setState(() {
        _hintText = null;
      });
    });
  }

  void startExercise() {
    final exercise = widget.exercises[currentExerciseIndex];
    setState(() {
      remainingTime = exercise.workSeconds;
      isRest = false;
    });
    _showHint('开始：${exercise.name}（第 $currentSet/${exercise.sets} 组）');
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    _animController
      ..reset()
      ..repeat();
    timer = Timer.periodic(Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    setState(() {
      if (remainingTime > 0) {
        remainingTime--;
      } else {
        timer?.cancel();
        _animController.stop();
        final exercise = widget.exercises[currentExerciseIndex];
        if (!isRest) {
          // 动作结束
          if (currentSet < exercise.sets) {
            // 还有下一组 -> 先判断是否需要组内休息
            if (exercise.intraRestSeconds > 0 && exercise.sets > 1) {
              _playCue(RestKind.intraSet);
              _showHint(
                  '组内休息：${exercise.intraRestValue}${exercise.intraRestUnit == TimeUnit.s ? 's' : 'min'}');
              _startRest(exercise.intraRestSeconds, RestKind.intraSet);
            } else {
              // 无组内休息，直接进入下一组
              currentSet++;
              _playCue();
              _showHint('继续：${exercise.name}（第 $currentSet/${exercise.sets} 组）');
              startExercise();
            }
          } else {
            // 当前动作所有组完成 -> 进入下一个动作或结束
            if (currentExerciseIndex < widget.exercises.length - 1) {
              final next = widget.exercises[currentExerciseIndex + 1];
              // 如果配置了组间休息，则先休息再进入下一个动作
              if (exercise.interRestSeconds > 0) {
                _playCue(RestKind.betweenExercise);
                _showHint(
                    '组间休息：${exercise.interRestValue}${exercise.interRestUnit == TimeUnit.s ? 's' : 'min'}');
                _startRest(exercise.interRestSeconds, RestKind.betweenExercise);
              } else {
                currentExerciseIndex++;
                currentSet = 1;
                _playCue();
                _showHint('下一个动作：${next.name}');
                startExercise();
              }
            } else {
              _playCue();
              _showDone();
            }
          }
        } else {
          // 休息结束
          if (_restKind == RestKind.intraSet) {
            // 组内休息结束 -> 下一组同一动作
            if (currentSet < exercise.sets) {
              currentSet++;
              _playCue();
              _showHint('继续：${exercise.name}（第 $currentSet/${exercise.sets} 组）');
              startExercise();
            } else {
              // 理论上不会到这里
              if (currentExerciseIndex < widget.exercises.length - 1) {
                currentExerciseIndex++;
                currentSet = 1;
                final next = widget.exercises[currentExerciseIndex];
                _playCue();
                _showHint('下一个动作：${next.name}');
                startExercise();
              } else {
                _playCue();
                _showDone();
              }
            }
          } else if (_restKind == RestKind.betweenExercise) {
            // 组间休息结束 -> 下一个动作第一组
            if (currentExerciseIndex < widget.exercises.length - 1) {
              currentExerciseIndex++;
              currentSet = 1;
              final next = widget.exercises[currentExerciseIndex];
              _playCue();
              _showHint('下一个动作：${next.name}');
              startExercise();
            } else {
              _playCue();
              _showDone();
            }
          } else {
            // 兜底逻辑
            if (currentExerciseIndex < widget.exercises.length - 1) {
              currentExerciseIndex++;
              currentSet = 1;
              final next = widget.exercises[currentExerciseIndex];
              _playCue();
              _showHint('下一个动作：${next.name}');
              startExercise();
            } else {
              _playCue();
              _showDone();
            }
          }
        }
      }
    });
  }

  void _startRest(int rest, RestKind kind) {
    setState(() {
      remainingTime = rest;
      isRest = true;
      _currentRestTotal = rest;
      _restKind = kind;
    });
    _startTimer();
  }

  void _showDone() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('完成！'),
              content: Text('恭喜，你完成了整个训练计划！'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context), child: Text('OK'))
              ],
            ));
  }

  @override
  void dispose() {
    _animController.dispose();
    timer?.cancel();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercises[currentExerciseIndex];
    return Scaffold(
      appBar: AppBar(title: Text('训练中')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: _hintText == null
                  ? SizedBox(height: 24, key: ValueKey('hint-empty'))
                  : Padding(
                      key: ValueKey('hint-text'),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _hintText!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 12),
            Text(isRest ? '休息中' : exercise.name,
                style: Theme.of(context).textTheme.displayLarge),
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: () {
                      final total = isRest
                          ? (_currentRestTotal > 0 ? _currentRestTotal : 0)
                          : (exercise.workSeconds > 0
                              ? exercise.workSeconds
                              : 0);
                      if (total <= 0) return 0.0;
                      final ratio = remainingTime / total;
                      return ratio.clamp(0.0, 1.0);
                    }(),
                    strokeWidth: 12,
                    color: Colors.deepPurple,
                  ),
                ),
                Text('$remainingTime',
                    style: Theme.of(context).textTheme.displayMedium)
              ],
            ),
            SizedBox(height: 20),
            Text('组数: $currentSet/${exercise.sets}',
                style: TextStyle(fontSize: 20))
          ],
        ),
      ),
    );
  }
}

//======================= 数据模型 =======================
enum ExerciseWorkType { time, reps }
enum TimeUnit { s, min }
enum RestKind { intraSet, betweenExercise }

class PlanGroup {
  String name;
  List<Exercise> exercises;
  bool pinned;
  PlanGroup({required this.name, required this.exercises, this.pinned = false});
}

class Exercise {
  String name;
  ExerciseWorkType workType;
  int workValue;
  TimeUnit workUnit; // 仅当 workType==time 时有意义；默认 s
  int workSeconds; // 计时用（统一换算成秒）
  int sets;
  // 组内休息（同一动作每组之间）
  int intraRestValue;
  TimeUnit intraRestUnit; // 默认 s
  int intraRestSeconds; // 计时用（统一换算成秒）
  // 组间休息（不同动作之间）
  int interRestValue;
  TimeUnit interRestUnit; // 默认 s
  int interRestSeconds; // 计时用（统一换算成秒）
  Exercise(
      {required this.name,
      required this.workType,
      required this.workValue,
      required this.workUnit,
      required this.workSeconds,
      required this.sets,
      required this.intraRestValue,
      required this.intraRestUnit,
      required this.intraRestSeconds,
      required this.interRestValue,
      required this.interRestUnit,
      required this.interRestSeconds});

  String get displaySummary {
    final workText = workType == ExerciseWorkType.time
        ? '$workValue ${workUnit == TimeUnit.s ? 's' : 'min'}'
        : '$workValue 次';
    final parts = <String>[];
    parts.add('$workText × $sets 组');
    if (intraRestValue > 0 && sets > 1) {
      final intraText =
          '$intraRestValue${intraRestUnit == TimeUnit.s ? 's' : 'min'}';
      parts.add('组内休息 $intraText');
    }
    if (interRestValue > 0) {
      final interText =
          '$interRestValue${interRestUnit == TimeUnit.s ? 's' : 'min'}';
      parts.add('组间休息 $interText');
    }
    return parts.join('，');
  }
}
