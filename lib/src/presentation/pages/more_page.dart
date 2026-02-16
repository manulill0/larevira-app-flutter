import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../offline/offline_sync_controller.dart';
import '../time/simulated_clock_controller.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_scaffold_background.dart';
import '../widgets/settings_section_card.dart';

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

  DateTime _easterSunday(int year) {
    // Anonymous Gregorian algorithm.
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  DateTime _palmSunday(int year) {
    return _easterSunday(year).subtract(const Duration(days: 7));
  }

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
                Text(
                  'Más',
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
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
                    subtitle: Text(
                      '${config.citySlug} · ${config.editionYear}',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SettingsSectionCard(
                  icon: Icons.schedule_send_outlined,
                  title: 'Reloj de pruebas',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              final palmSunday = _palmSunday(
                                config.editionYear,
                              );
                              final lastYearPreset = DateTime(
                                palmSunday.year,
                                palmSunday.month,
                                palmSunday.day,
                                19,
                                0,
                              );
                              simulatedClockController.setSimulatedNow(
                                lastYearPreset,
                              );
                            },
                            icon: const Icon(Icons.history_toggle_off),
                            label: Text('Preset ${config.editionYear}'),
                          ),
                          if (simulatedNow != null)
                            TextButton.icon(
                              onPressed:
                                  simulatedClockController.clearSimulation,
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
                const SizedBox(height: 8),
                SettingsSectionCard(
                  icon: Icons.brightness_6_outlined,
                  title: 'Apariencia',
                  child: SegmentedButton<ThemeMode>(
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
                ),
                const SizedBox(height: 8),
                SettingsSectionCard(
                  icon: Icons.download_for_offline_outlined,
                  title: 'Datos offline',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Última sincronización: $lastSyncText'),
                      const SizedBox(height: 8),
                      if (offlineSyncController.isSyncing) ...[
                        LinearProgressIndicator(
                          value: offlineSyncController.progress,
                        ),
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
                      OutlinedButton.icon(
                        onPressed: offlineSyncController.isSyncing
                            ? null
                            : () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    title: const Text('Limpiar caché local'),
                                    content: const Text(
                                      'Se borrará la caché de datos y de API almacenada en el dispositivo. Después tendrás que volver a sincronizar.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(
                                          dialogContext,
                                        ).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.of(
                                          dialogContext,
                                        ).pop(true),
                                        child: const Text('Limpiar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed != true || !context.mounted) {
                                  return;
                                }

                                await offlineSyncController.clearLocalCache();
                                if (!context.mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Caché local eliminada. Sincroniza de nuevo para recargar datos.',
                                    ),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.cleaning_services_outlined),
                        label: const Text('Limpiar caché local'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Recomendación: sincroniza en Wi-Fi antes de ir a la zona de mayor afluencia.',
                      ),
                    ],
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
