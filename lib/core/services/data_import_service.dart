import 'dart:convert' show utf8;
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/models/workout_history.dart';
import '../../data/workout_history_repository.dart';
import '../di/injection.dart';

/// Workout history import: parse CSV and batch write to Isar.
abstract class DataImportService {
  /// Pick CSV file and import; returns count, null on cancel/failure, -1 on parse error.
  Future<int?> importFromCsvFile();
}

class DataImportServiceImpl implements DataImportService {
  DataImportServiceImpl._();
  static final DataImportServiceImpl _instance = DataImportServiceImpl._();
  factory DataImportServiceImpl() => _instance;

  @override
  Future<int?> importFromCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null || path.isEmpty) return null;

    final file = File(path);
    if (!await file.exists()) return null;

    String raw;
    try {
      raw = await file.readAsString(encoding: utf8);
    } catch (_) {
      return -1;
    }

    List<List<dynamic>> rows;
    try {
      rows = const CsvToListConverter().convert(raw);
    } catch (_) {
      return -1;
    }

    if (rows.isEmpty) return 0;
    final header = rows.first.map((e) => e.toString()).toList();
    final dataRows = rows.skip(1).toList();
    if (dataRows.isEmpty) return 0;

    final records = <WorkoutHistory>[];
    for (final row in dataRows) {
      // Support old format (6 cols) and new format (7 cols with id)
      if (row.length < 6) continue;

      // Detect id column: new format has header 'id' and first column numeric
      final hasIdColumn = header.isNotEmpty && header[0].toLowerCase() == 'id' && row.length >= 7;
      
      final offset = hasIdColumn ? 1 : 0;
      final planId = _cell(row, header, offset);
      final planTitle = _cell(row, header, offset + 1);
      final startTimeStr = _cell(row, header, offset + 2);
      final totalSecStr = _cell(row, header, offset + 3);
      final caloriesStr = _cell(row, header, offset + 4);
      final rateStr = _cell(row, header, offset + 5);
      if (planId.isEmpty || startTimeStr.isEmpty) continue;

      DateTime startTime;
      try {
        startTime = DateTime.parse(startTimeStr);
      } catch (_) {
        continue;
      }
      final totalSec = int.tryParse(totalSecStr) ?? 0;
      final calories = int.tryParse(caloriesStr) ?? 0;
      final rate = double.tryParse(rateStr) ?? 1.0;

      records.add(WorkoutHistory.fromValues(
        planId: planId,
        planTitle: planTitle.isEmpty ? 'Imported' : planTitle,
        startTime: startTime,
        totalDurationSeconds: totalSec,
        calories: calories,
        completionRate: rate.clamp(0.0, 1.0),
      ));
    }
    if (records.isEmpty) return 0;
    final repo = getIt<WorkoutHistoryRepository>();
    await repo.putAll(records);
    // Isar compact could be triggered here when API is available (Isar 3.x has no compact)
    return records.length;
  }

  String _cell(List<dynamic> row, List<String> header, int index) {
    if (index >= row.length) return '';
    return row[index].toString().trim();
  }
}
