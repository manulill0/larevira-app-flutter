import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../offline/offline_sync_controller.dart';
import '../widgets/app_scaffold_background.dart';

class MorePage extends StatelessWidget {
  const MorePage({
    super.key,
    required this.config,
    required this.offlineSyncController,
  });

  final AppConfig config;
  final OfflineSyncController offlineSyncController;

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBackground(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: offlineSyncController,
          builder: (context, child) {
            final lastSync = offlineSyncController.lastSyncedAt;
            final lastSyncText = lastSync == null
                ? 'Nunca'
                : DateFormat('dd/MM/yyyy HH:mm').format(lastSync);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Text('Más', style: Theme.of(context).appBarTheme.titleTextStyle),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.public),
                    title: const Text('API base URL'),
                    subtitle: Text(config.baseUrl),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_city),
                    title: const Text('Ciudad / Edición'),
                    subtitle: Text('${config.citySlug} · ${config.editionYear}'),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.download_for_offline_outlined),
                            SizedBox(width: 8),
                            Text(
                              'Datos offline',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Última sincronización: $lastSyncText'),
                        const SizedBox(height: 8),
                        if (offlineSyncController.isSyncing) ...[
                          LinearProgressIndicator(value: offlineSyncController.progress),
                          const SizedBox(height: 8),
                          Text(
                            'Descargando ${offlineSyncController.completedSteps}/'
                            '${offlineSyncController.totalSteps} paquetes...',
                          ),
                        ],
                        if (offlineSyncController.lastError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${offlineSyncController.lastError}',
                            style: const TextStyle(color: Color(0xFFA02943)),
                          ),
                        ],
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: offlineSyncController.isSyncing
                              ? null
                              : () => offlineSyncController.syncAll(),
                          icon: const Icon(Icons.download),
                          label: Text(
                            offlineSyncController.isSyncing
                                ? 'Sincronizando...'
                                : 'Descargar datos offline ahora',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Recomendación: sincroniza en Wi-Fi antes de ir a la zona de mayor afluencia.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
