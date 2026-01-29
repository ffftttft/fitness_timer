import 'package:isar/isar.dart';

import 'models/timer_snapshot.dart';

/// Snapshot repository: save, query by kind+sourceId, query by max age, clear.
abstract class TimerSnapshotRepository {
  /// Save one snapshot (replaces any existing for same kind+sourceId so there is at most one per source).
  Future<void> save(TimerSnapshot snapshot);

  /// Get the latest snapshot for the given kind+sourceId, or null.
  Future<TimerSnapshot?> getLatest(String kind, String sourceId);

  /// Get the latest snapshot for kind+sourceId within [maxAge]; returns null if none or expired.
  Future<TimerSnapshot?> getLatestWithin(
    String kind,
    String sourceId,
    Duration maxAge,
  );

  /// Delete all snapshots for kind+sourceId (e.g. after recovery to avoid re-entering recovery).
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
