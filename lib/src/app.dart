import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_config.dart';
import 'data/repositories/larevira_repository.dart';
import 'presentation/bootstrap_page.dart';
import 'presentation/favorites/favorites_controller.dart';
import 'presentation/mode/mode_controller.dart';
import 'presentation/offline/offline_sync_controller.dart';
import 'presentation/planning/planning_controller.dart';
import 'presentation/time/simulated_clock_controller.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/theme_controller.dart';

class LaReviraApp extends StatelessWidget {
  const LaReviraApp({
    super.key,
    required this.favoritesController,
    required this.planningController,
    required this.offlineSyncController,
    required this.modeController,
    required this.themeController,
    required this.simulatedClockController,
    required this.repository,
    required this.config,
  });

  final FavoritesController favoritesController;
  final PlanningController planningController;
  final OfflineSyncController offlineSyncController;
  final ModeController modeController;
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
          locale: const Locale('es', 'ES'),
          supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: themeController.mode,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: BootstrapPage(
            repository: repository,
            config: config,
            favoritesController: favoritesController,
            planningController: planningController,
            offlineSyncController: offlineSyncController,
            modeController: modeController,
            themeController: themeController,
            simulatedClockController: simulatedClockController,
          ),
        );
      },
    );
  }
}
