import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
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
  });

  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final PlanningController planningController;
  final SimulatedClockController simulatedClockController;

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  late String _mode = widget.config.mode;

  void _onModeChanged(String mode) {
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'all', label: Text('All')),
                      ButtonSegment(value: 'live', label: Text('Live')),
                      ButtonSegment(value: 'official', label: Text('Oficial')),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (value) => _onModeChanged(value.first),
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
