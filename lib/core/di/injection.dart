import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../audio/tone_player.dart';
import '../../core/audio/tts_service.dart';
import '../../core/notifications/timer_notification_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/timer_background_service.dart';
import '../../core/services/data_export_service.dart';
import '../../core/services/data_import_service.dart';
// import '../../core/services/health_sync_service.dart'; // TODO: 暂时禁用 health 插件
import '../../core/services/recovery_hint_service.dart';
import '../../core/services/timer_background_service_impl.dart';
import '../../data/models/timer_snapshot.dart';
import '../../data/models/workout_history.dart';
import '../../data/timer_snapshot_repository.dart';
import '../../data/workout_history_repository.dart';
import '../../domain/timer/interval_builder.dart';
import '../../domain/timer/interval_engine.dart';
import '../../domain/timer/plan_interval_builder.dart';
import '../../models/workout_config.dart';
import '../../models/workout_model.dart';

/// 全局依赖注入容器
///
/// 当前阶段注册：
/// - IntervalEngine 工厂
/// - WorkoutConfig / WorkoutPlan 对应的 IntervalBuilder
/// - 声音 & TTS & 通知服务
final GetIt getIt = GetIt.instance;

bool _initialized = false;

// 工厂 typedef，方便在上层通过 getIt 调用。
typedef IntervalEngineFactory = IntervalEngine Function(List<Interval> intervals);
typedef WorkoutConfigIntervalBuilderFactory = WorkoutConfigIntervalBuilder Function(
  WorkoutConfig config,
);
typedef PlanIntervalBuilderFactory = PlanIntervalBuilder Function(WorkoutPlan plan);

Future<void> configureDependencies() async {
  if (_initialized) return;
  _initialized = true;

  // IntervalEngine 工厂
  getIt.registerFactory<IntervalEngineFactory>(
    () => (intervals) => IntervalEngine(intervals: intervals),
  );

  // IntervalBuilder 工厂
  getIt.registerFactory<WorkoutConfigIntervalBuilderFactory>(
    () => (config) => WorkoutConfigIntervalBuilder(config),
  );
  getIt.registerFactory<PlanIntervalBuilderFactory>(
    () => (plan) => PlanIntervalBuilder(plan),
  );

  // 声音 / 语音 / 通知 / 触觉服务
  getIt.registerLazySingleton<TonePlayer>(() => TonePlayer.instance);
  getIt.registerLazySingleton<TtsService>(() => TtsService.instance);
  getIt.registerLazySingleton<TimerNotificationService>(
    () => const TimerNotificationServiceImpl(),
  );
  getIt.registerLazySingleton<HapticService>(() => HapticServiceImpl());
  getIt.registerLazySingleton<TimerBackgroundService>(
    () => TimerBackgroundServiceImpl(),
  );
  getIt.registerLazySingleton<DataExportService>(() => DataExportServiceImpl());
  getIt.registerLazySingleton<DataImportService>(() => DataImportServiceImpl());
  // getIt.registerLazySingleton<HealthSyncService>(() => HealthSyncServiceImpl()); // TODO: 暂时禁用 health 插件
  getIt.registerLazySingleton<RecoveryHintService>(() => RecoveryHintServiceImpl());

  // 启动计数：每 10 次启动执行 Isar 碎片整理（compactOnLaunch）
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  const launchCountKey = 'isar_compact_launch_count';
  final launchCount = (prefs.getInt(launchCountKey) ?? 0) + 1;
  await prefs.setInt(launchCountKey, launchCount);

  // Isar 与快照/历史仓储（断点续传 + 训练历史）；每 10 次启动仅做计数，compact 可待 Isar 支持时接入
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [TimerSnapshotSchema, WorkoutHistorySchema],
    directory: dir.path,
  );
  getIt.registerLazySingleton<Isar>(() => isar);
  getIt.registerLazySingleton<TimerSnapshotRepository>(
    () => TimerSnapshotRepositoryImpl(getIt<Isar>()),
  );
  getIt.registerLazySingleton<WorkoutHistoryRepository>(
    () => WorkoutHistoryRepositoryImpl(getIt<Isar>()),
  );
}


