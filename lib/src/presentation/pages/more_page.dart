import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../offline/offline_sync_controller.dart';
import '../time/simulated_clock_controller.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_scaffold_background.dart';

class MorePage extends StatelessWidget {
  const MorePage({
    super.key,
    required this.config,
    required this.offlineSyncController,
    required this.themeController,
    required this.simulatedClockController,
  });

  final AppConfig config;
  final OfflineSyncController offlineSyncController;
  final ThemeController themeController;
  final SimulatedClockController simulatedClockController;

  Future<void> _pickSimulationDateTime(BuildContext context) async {
    final now = simulatedClockController.now;
    final firstDate = DateTime(2020, 1, 1);
    final lastDate = DateTime(2035, 12, 31);
    final candidateInitial = simulatedClockController.simulatedNow ?? now;
    final initialDate = candidateInitial.isBefore(firstDate)
        ? firstDate
        : candidateInitial.isAfter(lastDate)
            ? lastDate
            : candidateInitial;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null || !context.mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) {
      return;
    }

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    await simulatedClockController.setSimulatedNow(selected);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBackground(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            offlineSyncController,
            themeController,
            simulatedClockController,
          ]),
          builder: (context, child) {
            final lastSync = offlineSyncController.lastSyncedAt;
            final lastSyncText = lastSync == null
                ? 'Nunca'
                : DateFormat('dd/MM/yyyy HH:mm').format(lastSync);
            final simulatedNow = simulatedClockController.simulatedNow;

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
                            Icon(Icons.schedule_send_outlined),
                            SizedBox(width: 8),
                            Text(
                              'Reloj de pruebas',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          simulatedNow == null
                              ? 'Usando hora real del dispositivo.'
                              : 'Fecha simulada activa: ${DateFormat('EEE dd/MM/yyyy HH:mm', 'es_ES').format(simulatedNow)}',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _pickSimulationDateTime(context),
                              icon: const Icon(Icons.edit_calendar_outlined),
                              label: const Text('Elegir fecha/hora'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                final lastYearPreset =
                                    DateTime(config.editionYear - 1, 4, 17, 19, 0);
                                simulatedClockController
                                    .setSimulatedNow(lastYearPreset);
                              },
                              icon: const Icon(Icons.history_toggle_off),
                              label: Text(
                                'Preset ${config.editionYear - 1}',
                              ),
                            ),
                            if (simulatedNow != null)
                              TextButton.icon(
                                onPressed: simulatedClockController.clearSimulation,
                                icon: const Icon(Icons.access_time),
                                label: const Text('Volver a hora real'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ayuda para QA: simula un día/hora de Semana Santa y valida estados temporales y orden por horas.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
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
                            Icon(Icons.brightness_6_outlined),
                            SizedBox(width: 8),
                            Text(
                              'Apariencia',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SegmentedButton<ThemeMode>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_outlined),
                              label: Text('Día'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_outlined),
                              label: Text('Noche'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: Icon(Icons.settings_suggest_outlined),
                              label: Text('Sistema'),
                            ),
                          ],
                          selected: {themeController.mode},
                          onSelectionChanged: (value) =>
                              themeController.setMode(value.first),
                        ),
                      ],
                    ),
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
