import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../data/repositories/larevira_repository.dart';
import 'favorites/favorites_controller.dart';
import 'offline/offline_sync_controller.dart';
import 'pages/brotherhoods_page.dart';
import 'pages/days_page.dart';
import 'pages/more_page.dart';
import 'pages/today_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.repository,
    required this.config,
    required this.favoritesController,
    required this.offlineSyncController,
  });

  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final OfflineSyncController offlineSyncController;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayPage(
        repository: widget.repository,
        config: widget.config,
        favoritesController: widget.favoritesController,
      ),
      DaysPage(
        repository: widget.repository,
        config: widget.config,
        favoritesController: widget.favoritesController,
      ),
      BrotherhoodsPage(
        repository: widget.repository,
        config: widget.config,
        favoritesController: widget.favoritesController,
      ),
      MorePage(
        config: widget.config,
        offlineSyncController: widget.offlineSyncController,
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
