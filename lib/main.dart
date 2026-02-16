import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/app.dart';
import 'src/config/app_config.dart';
import 'src/data/api/api_client.dart';
import 'src/data/local/app_database.dart';
import 'src/data/repositories/larevira_repository.dart';
import 'src/presentation/favorites/favorites_controller.dart';
import 'src/presentation/offline/offline_sync_controller.dart';
import 'src/presentation/time/simulated_clock_controller.dart';
import 'src/presentation/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');

  final config = AppConfig.fromEnvironment();
  final appDatabase = AppDatabase();
  final repository = LareviraRepository(
    apiClient: ApiClient(baseUrl: config.baseUrl),
    appDatabase: appDatabase,
  );
  final favoritesController = await FavoritesController.create();
  final offlineSyncController = await OfflineSyncController.create(
    repository: repository,
    config: config,
  );
  final themeController = await ThemeController.create();
  final simulatedClockController = await SimulatedClockController.create(
    initialSimulatedNow: config.simulatedNowFromEnv,
  );

  runApp(
    LaReviraApp(
      favoritesController: favoritesController,
      offlineSyncController: offlineSyncController,
      themeController: themeController,
      simulatedClockController: simulatedClockController,
      repository: repository,
      config: config,
    ),
  );
}
