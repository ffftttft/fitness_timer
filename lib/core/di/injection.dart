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
// import '../../core/services/health_sync_service.dart'; // TODO: health plugin disabled
import '../../core/services/health_sync_status.dart';
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

/// Global dependency injection container.
///
/// Registers: IntervalEngine factory, IntervalBuilders for WorkoutConfig/WorkoutPlan,
/// audio / TTS / notification services.
final GetIt getIt = GetIt.instance;

bool _initialized = false;
typedef IntervalEngineFactory = IntervalEngine Function(List<Interval> intervals);
typedef WorkoutConfigIntervalBuilderFactory = WorkoutConfigIntervalBuilder Function(
  WorkoutConfig config,
);
typedef PlanIntervalBuilderFactory = PlanIntervalBuilder Function(WorkoutPlan plan);

Future<void> configureDependencies() async {
  if (_initialized) return;
  _initialized = true;

  getIt.registerFactory<IntervalEngineFactory>(
    () => (intervals) => IntervalEngine(intervals: intervals),
  );

  // IntervalBuilder factories
  getIt.registerFactory<WorkoutConfigIntervalBuilderFactory>(
    () => (config) => WorkoutConfigIntervalBuilder(config),
  );
  getIt.registerFactory<PlanIntervalBuilderFactory>(
    () => (plan) => PlanIntervalBuilder(plan),
  );

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
  // getIt.registerLazySingleton<HealthSyncService>(() => HealthSyncServiceImpl()); // TODO: health plugin disabled
  getIt.registerLazySingleton<HealthSyncStatus>(() => HealthSyncStatusStub());
  getIt.registerLazySingleton<RecoveryHintService>(() => RecoveryHintServiceImpl());

  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  const launchCountKey = 'isar_compact_launch_count';
  final launchCount = (prefs.getInt(launchCountKey) ?? 0) + 1;
  await prefs.setInt(launchCountKey, launchCount);

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


