import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/app_config.dart';
import 'data/repositories/larevira_repository.dart';
import 'presentation/bootstrap_page.dart';
import 'presentation/favorites/favorites_controller.dart';
import 'presentation/offline/offline_sync_controller.dart';

class LaReviraApp extends StatelessWidget {
  const LaReviraApp({
    super.key,
    required this.favoritesController,
    required this.offlineSyncController,
    required this.repository,
    required this.config,
  });

  final FavoritesController favoritesController;
  final OfflineSyncController offlineSyncController;
  final LareviraRepository repository;
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF8B1E3F),
        secondary: Color(0xFFC9983E),
        surface: Color(0xFFFFFAF4),
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'La Revira',
      theme: base.copyWith(
        textTheme: GoogleFonts.loraTextTheme(base.textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF2D1B11),
          elevation: 0,
          titleTextStyle: GoogleFonts.cinzel(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D1B11),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFAF4),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: BootstrapPage(
        repository: repository,
        config: config,
        favoritesController: favoritesController,
        offlineSyncController: offlineSyncController,
      ),
    );
  }
}
