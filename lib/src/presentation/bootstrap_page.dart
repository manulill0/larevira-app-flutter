import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_config.dart';
import '../data/repositories/larevira_repository.dart';
import 'favorites/favorites_controller.dart';
import 'home_shell.dart';
import 'offline/offline_sync_controller.dart';
import 'planning/planning_controller.dart';
import 'time/simulated_clock_controller.dart';
import 'theme/app_colors.dart';
import 'theme/theme_controller.dart';

class BootstrapPage extends StatefulWidget {
  const BootstrapPage({
    super.key,
    required this.repository,
    required this.config,
    required this.favoritesController,
    required this.planningController,
    required this.offlineSyncController,
    required this.themeController,
    required this.simulatedClockController,
  });

  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final PlanningController planningController;
  final OfflineSyncController offlineSyncController;
  final ThemeController themeController;
  final SimulatedClockController simulatedClockController;

  @override
  State<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage>
    with SingleTickerProviderStateMixin {
  bool _ready = false;
  late final AnimationController _animationController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _start();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    await Future.wait<void>([
      widget.offlineSyncController.maybeSyncOnStartup(),
      Future<void>.delayed(const Duration(milliseconds: 900)),
    ]);

    if (!mounted) {
      return;
    }
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return HomeShell(
        repository: widget.repository,
        config: widget.config,
        favoritesController: widget.favoritesController,
        planningController: widget.planningController,
        offlineSyncController: widget.offlineSyncController,
        themeController: widget.themeController,
        simulatedClockController: widget.simulatedClockController,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.scaffoldGradient(isDark: isDark),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListenableBuilder(
                listenable: widget.offlineSyncController,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: AppColors.splashIcon(
                              isDark: isDark,
                            ).withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.church_outlined,
                            size: 46,
                            color: AppColors.splashIcon(isDark: isDark),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'La Revira',
                        style: GoogleFonts.cinzel(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.splashTitle(isDark: isDark),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.config.citySlug.toUpperCase()} ${widget.config.editionYear}',
                        style: const TextStyle(
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 14),
                      Text(
                        widget.offlineSyncController.isSyncing
                            ? 'Sincronizando datos para uso offline...'
                            : 'Preparando la app...',
                        textAlign: TextAlign.center,
                      ),
                      if (widget.offlineSyncController.isSyncing) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            width: 210,
                            child: LinearProgressIndicator(
                              value: widget.offlineSyncController.progress,
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.offlineSyncController.completedSteps}/'
                          '${widget.offlineSyncController.totalSteps} paquetes',
                        ),
                      ],
                      if (widget.offlineSyncController.lastError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Continuando con caché: ${widget.offlineSyncController.lastError}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
