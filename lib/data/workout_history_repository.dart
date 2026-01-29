import 'package:isar/isar.dart';

import 'models/workout_history.dart';

/// 训练历史仓储：写入单条/批量、查询全部（供导出与增量回装）。
abstract class WorkoutHistoryRepository {
  Future<void> save(WorkoutHistory record);
  /// 批量写入（putAll），用于导入备份；新记录使用 Isar 自增 ID，避免冲突。
  Future<void> putAll(List<WorkoutHistory> records);
  Future<List<WorkoutHistory>> getAllSortedByStartTimeDesc();
  /// 批量删除指定 ID 的记录。
  Future<void> deleteByIds(List<int> ids);
}

class WorkoutHistoryRepositoryImpl implements WorkoutHistoryRepository {
  WorkoutHistoryRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<void> save(WorkoutHistory record) async {
    await _isar.writeTxn(() async {
      await _isar.workoutHistorys.put(record);
    });
  }

  @override
  Future<void> putAll(List<WorkoutHistory> records) async {
    if (records.isEmpty) return;
    await _isar.writeTxn(() async {
      await _isar.workoutHistorys.putAll(records);
    });
  }

  @override
  Future<List<WorkoutHistory>> getAllSortedByStartTimeDesc() async {
    return _isar.workoutHistorys
        .where()
        .sortByStartTimeDesc()
        .findAll();
  }

  @override
  Future<void> deleteByIds(List<int> ids) async {
    if (ids.isEmpty) return;
    await _isar.writeTxn(() async {
      await _isar.workoutHistorys.deleteAll(ids);
    });
  }
}
