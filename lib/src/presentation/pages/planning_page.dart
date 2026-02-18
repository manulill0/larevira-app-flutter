import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/app_config.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../mode/mode_controller.dart';
import '../planning/planning_controller.dart';
import '../time/simulated_clock_controller.dart';
import '../widgets/app_scaffold_background.dart';
import 'day_brotherhoods_page.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({
    super.key,
    required this.repository,
    required this.config,
    required this.favoritesController,
    required this.planningController,
    required this.simulatedClockController,
    required this.modeController,
  });

  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final PlanningController planningController;
  final SimulatedClockController simulatedClockController;
  final ModeController modeController;

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  late String _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.modeController.mode;
    widget.modeController.addListener(_onModeChanged);
  }

  @override
  void dispose() {
    widget.modeController.removeListener(_onModeChanged);
    super.dispose();
  }

  void _onModeChanged() {
    final mode = widget.modeController.mode;
    if (mode == _mode) {
      return;
    }
    setState(() => _mode = mode);
  }

  Future<void> _shareAll() async {
    final entries = widget.planningController.all(
      citySlug: widget.config.citySlug,
      year: widget.config.editionYear,
      mode: _mode,
    );
    await _shareEntries(entries: entries, title: 'Mi planning completo');
  }

  Future<void> _shareDay() async {
    final entries = widget.planningController.all(
      citySlug: widget.config.citySlug,
      year: widget.config.editionYear,
      mode: _mode,
    );
    if (entries.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay puntos en el planning para compartir.'),
        ),
      );
      return;
    }

    final grouped = <String, List<PlanningEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.daySlug, () => <PlanningEntry>[]).add(entry);
    }

    final daySlugs = grouped.keys.toList(growable: false)
      ..sort((a, b) {
        final firstA = grouped[a]!.first.plannedAt;
        final firstB = grouped[b]!.first.plannedAt;
        return firstA.compareTo(firstB);
      });

    final selectedDaySlug = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            children: [
              const ListTile(
                title: Text('Compartir una jornada'),
                subtitle: Text('Elige el día que quieres compartir'),
              ),
              for (final daySlug in daySlugs)
                ListTile(
                  title: Text(grouped[daySlug]!.first.dayName),
                  subtitle: Text(
                    '${grouped[daySlug]!.length} puntos planificados',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pop(daySlug),
                ),
            ],
          ),
        );
      },
    );

    if (selectedDaySlug == null) {
      return;
    }

    final dayEntries = grouped[selectedDaySlug]!;
    final dayName = dayEntries.first.dayName;
    await _shareEntries(entries: dayEntries, title: 'Planning de $dayName');
  }

  Future<void> _shareEntries({
    required List<PlanningEntry> entries,
    required String title,
  }) async {
    if (entries.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay puntos en el planning para compartir.'),
        ),
      );
      return;
    }

    String shareUrl;
    try {
      shareUrl = await widget.repository.createPlanningShare(
        citySlug: widget.config.citySlug,
        year: widget.config.editionYear,
        mode: _mode,
        entries: entries.map((entry) => entry.toJson()).toList(growable: false),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo generar el enlace compartido. Revisa tu conexión.',
          ),
        ),
      );
      return;
    }

    await SharePlus.instance.share(
      ShareParams(subject: 'Planning La Revira', text: '$title\n\n$shareUrl'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Mi planning',
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
                  const Spacer(),
                  ListenableBuilder(
                    listenable: widget.planningController,
                    builder: (context, child) {
                      final count = widget.planningController
                          .all(
                            citySlug: widget.config.citySlug,
                            year: widget.config.editionYear,
                            mode: _mode,
                          )
                          .length;
                      return Chip(
                        avatar: const Icon(
                          Icons.event_note_outlined,
                          size: 16,
                          color: Color(0xFF8B1E3F),
                        ),
                        label: Text('$count planes'),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Compartir planning',
                    onSelected: (value) {
                      if (value == 'all') {
                        _shareAll();
                      } else if (value == 'day') {
                        _shareDay();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'all',
                        child: Text('Compartir planning completo'),
                      ),
                      PopupMenuItem<String>(
                        value: 'day',
                        child: Text('Compartir una jornada'),
                      ),
                    ],
                    icon: const Icon(Icons.share_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.planningController,
                builder: (context, child) {
                  final entries = widget.planningController.all(
                    citySlug: widget.config.citySlug,
                    year: widget.config.editionYear,
                    mode: _mode,
                  );

                  if (entries.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aun no tienes puntos planificados. Anadelos desde cada jornada con el icono de agenda.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final grouped = <String, List<PlanningEntry>>{};
                  for (final entry in entries) {
                    grouped
                        .putIfAbsent(entry.daySlug, () => <PlanningEntry>[])
                        .add(entry);
                  }
                  final daySlugs = grouped.keys.toList(growable: false)
                    ..sort((a, b) {
                      final firstA = grouped[a]!.first.plannedAt;
                      final firstB = grouped[b]!.first.plannedAt;
                      return firstA.compareTo(firstB);
                    });

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemBuilder: (context, index) {
                      final daySlug = daySlugs[index];
                      final dayEntries = [...grouped[daySlug]!]
                        ..sort((a, b) => a.plannedAt.compareTo(b.plannedAt));
                      final dayName = dayEntries.first.dayName;
                      final subtitle = DateFormat(
                        'EEEE d MMMM',
                        'es_ES',
                      ).format(dayEntries.first.plannedAt);

                      return Card(
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Text(dayName),
                          subtitle: Text(subtitle),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            8,
                            0,
                            8,
                            8,
                          ),
                          children: [
                            for (final entry in dayEntries)
                              ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                leading: const Icon(
                                  Icons.event_available,
                                  color: Color(0xFF8B1E3F),
                                ),
                                title: Text(entry.brotherhoodName),
                                subtitle: Text(
                                  '${entry.pointName} · ${DateFormat('HH:mm').format(entry.plannedAt)}',
                                ),
                                trailing: IconButton(
                                  tooltip: 'Quitar del planning',
                                  onPressed: () =>
                                      widget.planningController.toggle(entry),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => DayBrotherhoodsPage(
                                        daySlug: entry.daySlug,
                                        dayName: entry.dayName,
                                        mode: _mode,
                                        repository: widget.repository,
                                        config: widget.config,
                                        favoritesController:
                                            widget.favoritesController,
                                        planningController:
                                            widget.planningController,
                                        simulatedClockController:
                                            widget.simulatedClockController,
                                        initialTabIndex: 3,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemCount: daySlugs.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
