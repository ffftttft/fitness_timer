import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/app_theme.dart';
import 'core/di/injection.dart';
import 'core/localization/app_language.dart';
import 'core/notifications/timer_notification_service.dart';
import 'core/services/timer_background_service_impl.dart';
import 'providers/app_language_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/workout_config_provider.dart';
import 'providers/workout_plan_provider.dart';
import 'views/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  await configureDependencies();
  await getIt<TimerNotificationService>().init();
  await TimerBackgroundServiceImpl.initForegroundTask();
  // Production error monitoring: Sentry disabled when DSN empty; set SENTRY_DSN to enable
  await SentryFlutter.init(
    (options) {
      options.dsn = '';
      options.tracesSampleRate = 0.0;
      options.environment = 'production';
    },
    appRunner: () => runApp(const ProviderScope(child: FitnessTimerApp())),
  );
}

class FitnessTimerApp extends StatelessWidget {
  const FitnessTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutPlanProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutConfigProvider()),
        ChangeNotifierProxyProvider<WorkoutConfigProvider, TimerProvider>(
          create: (context) => TimerProvider(
            config: context.read<WorkoutConfigProvider>().config,
          ),
          update: (context, cfg, timer) {
            timer ??= TimerProvider(config: cfg.config);
            // ignore: discarded_futures
            timer.setConfig(cfg.config);
            return timer;
          },
        ),
      ],
      child: Consumer<AppLanguageProvider>(
        builder: (context, langProvider, _) {
          final lang = langProvider.language;
          // We do not change Flutter's Locale here; only our own strings.
          return MaterialApp(
            title: lang == AppLanguage.en ? 'Fitness Timer' : '健身计时器',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark(),
            home: const HomeView(),
          );
        },
      ),
    );
  }
}

