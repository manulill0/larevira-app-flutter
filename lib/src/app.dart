import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'data/repositories/larevira_repository.dart';
import 'presentation/bootstrap_page.dart';
import 'presentation/favorites/favorites_controller.dart';
import 'presentation/offline/offline_sync_controller.dart';
import 'presentation/time/simulated_clock_controller.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/theme_controller.dart';

class LaReviraApp extends StatelessWidget {
  const LaReviraApp({
    super.key,
    required this.favoritesController,
    required this.offlineSyncController,
    required this.themeController,
    required this.simulatedClockController,
    required this.repository,
    required this.config,
  });

  final FavoritesController favoritesController;
  final OfflineSyncController offlineSyncController;
  final ThemeController themeController;
  final SimulatedClockController simulatedClockController;
  final LareviraRepository repository;
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'La Revira',
          themeMode: themeController.mode,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: BootstrapPage(
            repository: repository,
            config: config,
            favoritesController: favoritesController,
            offlineSyncController: offlineSyncController,
            themeController: themeController,
            simulatedClockController: simulatedClockController,
          ),
        );
      },
    );
  }
}
