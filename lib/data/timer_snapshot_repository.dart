import 'package:isar/isar.dart';

import 'models/timer_snapshot.dart';

/// 快照仓储：写入、按 kind+sourceId 查询、按效期查询、清空。
abstract class TimerSnapshotRepository {
  /// 异步写入一条快照（会先删除同 kind+sourceId 的旧记录，再写入一条，保证每源仅一条）。
  Future<void> save(TimerSnapshot snapshot);

  /// 获取指定 kind+sourceId 的最新一条快照（无则 null）。
  Future<TimerSnapshot?> getLatest(String kind, String sourceId);

  /// 获取指定 kind+sourceId 且在 [maxAge] 内的最新快照；超龄返回 null。
  Future<TimerSnapshot?> getLatestWithin(
    String kind,
    String sourceId,
    Duration maxAge,
  );

  /// 删除指定 kind+sourceId 的所有快照（恢复后清空，避免循环恢复）。
  Future<void> clear(String kind, String sourceId);
}

class TimerSnapshotRepositoryImpl implements TimerSnapshotRepository {
  TimerSnapshotRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<void> save(TimerSnapshot snapshot) async {
    await _isar.writeTxn(() async {
      await _isar.timerSnapshots
          .where()
          .filter()
          .kindEqualTo(snapshot.kind)
          .and()
          .sourceIdEqualTo(snapshot.sourceId)
          .deleteAll();
      await _isar.timerSnapshots.put(snapshot);
    });
  }

  @override
  Future<TimerSnapshot?> getLatest(String kind, String sourceId) async {
    return _isar.timerSnapshots
        .where()
        .filter()
        .kindEqualTo(kind)
        .and()
        .sourceIdEqualTo(sourceId)
        .sortByLastUpdatedAtWallDesc()
        .findFirst();
  }

  @override
  Future<TimerSnapshot?> getLatestWithin(
    String kind,
    String sourceId,
    Duration maxAge,
  ) async {
    final cutoff = DateTime.now().subtract(maxAge);
    return _isar.timerSnapshots
        .where()
        .filter()
        .kindEqualTo(kind)
        .and()
        .sourceIdEqualTo(sourceId)
        .and()
        .lastUpdatedAtWallGreaterThan(cutoff)
        .sortByLastUpdatedAtWallDesc()
        .findFirst();
  }

  @override
  Future<void> clear(String kind, String sourceId) async {
    await _isar.writeTxn(() async {
      await _isar.timerSnapshots
          .where()
          .filter()
          .kindEqualTo(kind)
          .and()
          .sourceIdEqualTo(sourceId)
          .deleteAll();
    });
  }
}
