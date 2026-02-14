import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../data/repositories/larevira_repository.dart';
import 'favorites/favorites_controller.dart';
import 'home_shell.dart';
import 'offline/offline_sync_controller.dart';

class BootstrapPage extends StatefulWidget {
  const BootstrapPage({
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
  State<BootstrapPage> createState() => _BootstrapPageState();
}

class _BootstrapPageState extends State<BootstrapPage> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _start();
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
        offlineSyncController: widget.offlineSyncController,
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F0E8), Color(0xFFF3E3CC)],
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
                      const Icon(Icons.church_outlined, size: 52, color: Color(0xFF8B1E3F)),
                      const SizedBox(height: 12),
                      const Text(
                        'La Revira',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
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
                          style: const TextStyle(color: Color(0xFFA02943)),
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
