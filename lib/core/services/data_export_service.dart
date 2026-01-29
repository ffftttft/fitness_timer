import 'dart:convert' show utf8;
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/workout_history.dart';
import '../../data/workout_history_repository.dart';
import '../di/injection.dart';

/// 训练历史导出服务：将 Isar WorkoutHistory 转为 CSV 并唤起系统分享。
abstract class DataExportService {
  /// 导出全部历史为 CSV 文件并唤起分享面板；无记录时返回 false。
  Future<bool> exportAndShareCsv();
  /// 导出选中的记录为 CSV 文件并唤起分享面板。
  Future<bool> exportSelectedRecords(List<WorkoutHistory> records);
}

class DataExportServiceImpl implements DataExportService {
  DataExportServiceImpl._();
  static final DataExportServiceImpl _instance = DataExportServiceImpl._();
  factory DataExportServiceImpl() => _instance;

  @override
  Future<bool> exportAndShareCsv() async {
    final repo = getIt<WorkoutHistoryRepository>();
    final list = await repo.getAllSortedByStartTimeDesc();
    if (list.isEmpty) return false;
    return _exportRecords(list, 'workout_history_all');
  }

  @override
  Future<bool> exportSelectedRecords(List<WorkoutHistory> records) async {
    if (records.isEmpty) return false;
    return _exportRecords(records, 'workout_history_selected');
  }

  Future<bool> _exportRecords(List<WorkoutHistory> list, String filePrefix) async {
    const header = [
      'id',
      'planId',
      'planTitle',
      'startTime',
      'totalDurationSeconds',
      'calories',
      'completionRate',
    ];
    final rows = [
      header,
      ...list.map((h) => [
            h.id.toString().padLeft(6, '0'),  // 6位数字格式的ID
            h.planId,
            h.planTitle,
            h.startTime.toIso8601String(),
            h.totalDurationSeconds.toString(),
            h.calories.toString(),
            h.completionRate.toString(),
          ]),
    ];
    final csv = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();
    final name = '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${dir.path}/$name');
    await file.writeAsString(csv, encoding: utf8);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Fitness Timer - Workout History',
      text: 'Workout history export (${list.length} record(s))',
    );
    return true;
  }
}
