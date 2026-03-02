import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/analytics/app_analytics.dart';
import 'src/app.dart';
import 'src/config/app_config.dart';
import 'src/data/api/api_client.dart';
import 'src/data/local/app_database.dart';
import 'src/data/repositories/larevira_repository.dart';
import 'src/presentation/favorites/favorites_controller.dart';
import 'src/live/live_update_controller.dart';
import 'src/presentation/maps/mapbox_map_helpers.dart';
import 'src/presentation/mode/mode_controller.dart';
import 'src/presentation/offline/offline_sync_controller.dart';
import 'src/presentation/planning/planning_controller.dart';
import 'src/presentation/time/simulated_clock_controller.dart';
import 'src/presentation/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  configureMapboxTokenIfPresent();
  await initializeDateFormatting('es_ES');

  final config = AppConfig.fromEnvironment();
  final analytics = await AppAnalytics.create(config);
  final appDatabase = AppDatabase();
  final repository = LareviraRepository(
    apiClient: ApiClient(baseUrl: config.baseUrl),
    appDatabase: appDatabase,
  );
  final favoritesController = await FavoritesController.create();
  final planningController = await PlanningController.create();
  final liveUpdateController = await LiveUpdateController.create(
    repository: repository,
    config: config,
  );
  final offlineSyncController = await OfflineSyncController.create(
    repository: repository,
    config: config,
  );
  final modeController = await ModeController.create(initialMode: config.mode);
  final themeController = await ThemeController.create();
  final simulatedClockController = await SimulatedClockController.create(
    initialSimulatedNow: config.simulatedNowFromEnv,
  );

  runApp(
    LaReviraApp(
      analytics: analytics,
      favoritesController: favoritesController,
      liveUpdateController: liveUpdateController,
      planningController: planningController,
      offlineSyncController: offlineSyncController,
      modeController: modeController,
      themeController: themeController,
      simulatedClockController: simulatedClockController,
      repository: repository,
      config: config,
    ),
  );

  analytics?.track('app_open');
}
