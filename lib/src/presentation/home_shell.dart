import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../data/repositories/larevira_repository.dart';
import 'favorites/favorites_controller.dart';
import 'mode/mode_controller.dart';
import 'offline/offline_sync_controller.dart';
import 'pages/brotherhoods_page.dart';
import 'pages/days_page.dart';
import 'pages/more_page.dart';
import 'pages/planning_page.dart';
import 'pages/today_page.dart';
import 'planning/planning_controller.dart';
import 'planning/planning_share_codec.dart';
import 'time/simulated_clock_controller.dart';
import 'theme/theme_controller.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.repository,
    required this.config,
    required this.favoritesController,
    required this.planningController,
    required this.offlineSyncController,
    required this.modeController,
    required this.themeController,
    required this.simulatedClockController,
  });

  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final PlanningController planningController;
  final OfflineSyncController offlineSyncController;
  final ModeController modeController;
  final ThemeController themeController;
  final SimulatedClockController simulatedClockController;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await _tryImportPlanningFromUri(initialUri);
    }

    _deepLinkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _tryImportPlanningFromUri(uri);
    });
  }

  Future<void> _tryImportPlanningFromUri(Uri uri) async {
    final shareSlug = PlanningShareCodec.shareSlugFromUri(uri);
    if (shareSlug != null && shareSlug.isNotEmpty) {
      try {
        final entriesJson = await widget.repository.getPlanningShareEntries(
          slug: shareSlug,
        );
        final entries = entriesJson
            .map(PlanningEntry.fromJson)
            .toList(growable: false);
        final inserted = await widget.planningController.upsertAll(entries);
        if (!mounted) {
          return;
        }
        setState(() => _index = 2);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              inserted == 0
                  ? 'Ese planning ya estaba importado.'
                  : 'Planning importado: $inserted puntos nuevos.',
            ),
          ),
        );
      } catch (_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo importar el planning compartido.'),
          ),
        );
      }
      return;
    }

    final payload = PlanningShareCodec.payloadFromUri(uri);
    if (payload == null || payload.isEmpty) {
      return;
    }
    final decoded = PlanningShareCodec.decodePayload(payload);
    if (decoded == null) {
      return;
    }

    final inserted = await widget.planningController.upsertAll(decoded.entries);
    if (!mounted) {
      return;
    }
    setState(() => _index = 2);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          inserted == 0
              ? 'Ese planning ya estaba importado.'
              : 'Planning importado: $inserted puntos nuevos.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayPage(
        repository: widget.repository,
        config: widget.config,
        favoritesController: widget.favoritesController,
        simulatedClockController: widget.simulatedClockController,
        modeController: widget.modeController,
      ),
      DaysPage(
        repository: widget.repository,
        config: widget.config,
        favoritesController: widget.favoritesController,
        planningController: widget.planningController,
        simulatedClockController: widget.simulatedClockController,
        modeController: widget.modeController,
      ),
      PlanningPage(
        repository: widget.repository,
        config: widget.config,
        favoritesController: widget.favoritesController,
        planningController: widget.planningController,
        simulatedClockController: widget.simulatedClockController,
        modeController: widget.modeController,
      ),
      BrotherhoodsPage(
        repository: widget.repository,
        config: widget.config,
        favoritesController: widget.favoritesController,
        simulatedClockController: widget.simulatedClockController,
      ),
      MorePage(
        config: widget.config,
        offlineSyncController: widget.offlineSyncController,
        modeController: widget.modeController,
        themeController: widget.themeController,
        simulatedClockController: widget.simulatedClockController,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Jornadas',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: 'Mi planning',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Hermandades',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Más',
          ),
        ],
      ),
    );
  }
}
