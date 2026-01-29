import 'package:isar/isar.dart';

import 'models/workout_history.dart';

/// Workout history repository: save single/batch, query all (for export and import).
abstract class WorkoutHistoryRepository {
  Future<void> save(WorkoutHistory record);
  /// Batch put (putAll) for import; new records use Isar auto-increment ID to avoid conflicts.
  Future<void> putAll(List<WorkoutHistory> records);
  Future<List<WorkoutHistory>> getAllSortedByStartTimeDesc();
  /// Delete records by the given IDs.
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
