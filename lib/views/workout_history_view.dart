import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/di/injection.dart';
import '../core/localization/app_language.dart';
import '../core/localization/app_strings.dart';
import '../core/services/data_export_service.dart';
import '../core/utils/time_format.dart';
import '../data/models/workout_history.dart';
import '../data/workout_history_repository.dart';
import '../providers/app_language_provider.dart';

/// Workout history list and export/delete screen.
class WorkoutHistoryView extends StatefulWidget {
  const WorkoutHistoryView({super.key});

  @override
  State<WorkoutHistoryView> createState() => _WorkoutHistoryViewState();
}

class _WorkoutHistoryViewState extends State<WorkoutHistoryView> {
  List<WorkoutHistory> _historyList = [];
  final Set<int> _selectedIds = {}; // selected record IDs
  bool _isLoading = true;
  bool _isSelectionMode = false; // batch selection mode

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    final repo = getIt<WorkoutHistoryRepository>();
    final list = await repo.getAllSortedByStartTimeDesc();
    setState(() {
      _historyList = list;
      _isLoading = false;
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    
    final lang = context.read<AppLanguageProvider>().language;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang == AppLanguage.en ? 'Delete records?' : '删除记录？'),
        content: Text(
          lang == AppLanguage.en
              ? 'Delete ${_selectedIds.length} selected record(s)? This cannot be undone.'
              : '删除 ${_selectedIds.length} 条选中的记录？此操作无法撤销。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang == AppLanguage.en ? 'Cancel' : '取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(lang == AppLanguage.en ? 'Delete' : '删除'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed || !mounted) return;

    final repo = getIt<WorkoutHistoryRepository>();
    await repo.deleteByIds(_selectedIds.toList());
    
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
    
    await _loadHistory();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == AppLanguage.en
                ? 'Records deleted'
                : '记录已删除',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportSelected() async {
    if (_selectedIds.isEmpty) return;
    
    final lang = context.read<AppLanguageProvider>().language;
    final selected = _historyList.where((h) => _selectedIds.contains(h.id)).toList();
    
    final exportService = getIt<DataExportService>();
    final success = await exportService.exportSelectedRecords(selected);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (lang == AppLanguage.en
                    ? 'Exported ${selected.length} record(s)'
                    : '已导出 ${selected.length} 条记录')
                : (lang == AppLanguage.en
                    ? 'Export failed'
                    : '导出失败'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds.addAll(_historyList.map((h) => h.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppLanguageProvider>().language;
    final s = AppStrings.of(context, lang);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == AppLanguage.en ? 'Workout history' : '训练历史'),
        actions: [
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: _selectAll,
              child: Text(lang == AppLanguage.en ? 'Select all' : '全选'),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _exitSelectionMode,
              tooltip: lang == AppLanguage.en ? 'Cancel' : '取消',
            ),
          ] else ...[
            if (_historyList.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.checklist),
                onPressed: _enterSelectionMode,
                tooltip: lang == AppLanguage.en ? 'Select mode' : '选择模式',
              ),
            IconButton(
              icon: const Icon(Icons.file_upload),
              tooltip: s.exportWorkoutHistoryTooltip,
              onPressed: _historyList.isEmpty
                  ? null
                  : () async {
                      final exportService = getIt<DataExportService>();
                      final success = await exportService.exportAndShareCsv();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? s.exportWorkoutHistory
                                  : s.exportNoData,
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyList.isEmpty
              ? Center(
                  child: Text(
                    lang == AppLanguage.en
                        ? 'No workout history yet.'
                        : '暂无训练历史。',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _historyList.length,
                  itemBuilder: (context, index) {
                    final record = _historyList[index];
                    final isSelected = _selectedIds.contains(record.id);
                    final completionPercent = (record.completionRate * 100).round();
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: _isSelectionMode
                            ? Checkbox(
                                value: isSelected,
                                onChanged: (_) => _toggleSelection(record.id),
                              )
                            : CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.fitness_center,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${record.id.toString().padLeft(6, '0')} ${record.planTitle.isEmpty
                                  ? (lang == AppLanguage.en ? 'Workout' : '训练')
                                  : record.planTitle}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDateTime(record.startTime, lang),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${lang == AppLanguage.en ? 'Duration' : '时长'}: ${formatMMSS(record.totalDurationSeconds)} · '
                              '${lang == AppLanguage.en ? 'Calories' : '卡路里'}: ${record.calories} kcal · '
                              '${lang == AppLanguage.en ? 'Complete' : '完成'}: ${(record.completionRate * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        onTap: _isSelectionMode
                            ? () => _toggleSelection(record.id)
                            : null,
                        onLongPress: !_isSelectionMode
                            ? () {
                                _enterSelectionMode();
                                _toggleSelection(record.id);
                              }
                            : null,
                      ),
                    );
                  },
                ),
      bottomSheet: _isSelectionMode && _selectedIds.isNotEmpty
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lang == AppLanguage.en
                            ? '${_selectedIds.length} selected'
                            : '已选择 ${_selectedIds.length} 项',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _exportSelected,
                      icon: const Icon(Icons.file_upload),
                      label: Text(lang == AppLanguage.en ? 'Export' : '导出'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _deleteSelected,
                      icon: const Icon(Icons.delete),
                      label: Text(lang == AppLanguage.en ? 'Delete' : '删除'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  String _formatDateTime(DateTime dt, AppLanguage lang) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inDays == 0) {
      return lang == AppLanguage.en
          ? 'Today ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
          : '今天 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return lang == AppLanguage.en
          ? 'Yesterday ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
          : '昨天 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }
}
