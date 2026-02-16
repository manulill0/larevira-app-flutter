import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../data/models/day_models.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../time/simulated_clock_controller.dart';
import '../widgets/app_scaffold_background.dart';
import 'day_brotherhoods_page.dart';

class DaysPage extends StatefulWidget {
  const DaysPage({
    super.key,
    required this.repository,
    required this.config,
    required this.favoritesController,
    required this.simulatedClockController,
  });

  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final SimulatedClockController simulatedClockController;

  @override
  State<DaysPage> createState() => _DaysPageState();
}

class _DaysPageState extends State<DaysPage> {
  late String _mode = widget.config.mode;
  late Future<List<DayIndexItem>> _daysFuture;

  @override
  void initState() {
    super.initState();
    _daysFuture = _loadDays();
  }

  Future<List<DayIndexItem>> _loadDays() {
    return widget.repository.getDays(
      citySlug: widget.config.citySlug,
      year: widget.config.editionYear,
      mode: _mode,
    );
  }

  void _onModeChanged(String mode) {
    setState(() {
      _mode = mode;
      _daysFuture = _loadDays();
    });
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
                        'Jornadas',
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                      const Spacer(),
                      ListenableBuilder(
                        listenable: widget.favoritesController,
                        builder: (context, child) {
                          return Chip(
                            avatar: const Icon(
                              Icons.star,
                              size: 16,
                              color: Color(0xFF8B1E3F),
                            ),
                            label: Text(
                              '${widget.favoritesController.all.length} favoritas',
                            ),
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
              child: FutureBuilder<List<DayIndexItem>>(
                future: _daysFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final days = snapshot.data ?? const <DayIndexItem>[];
                  if (days.isEmpty) {
                    return const Center(child: Text('Sin jornadas para este modo.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final startsAt = day.startsAt == null
                          ? 'Sin hora'
                          : DateFormat('EEEE d, HH:mm').format(day.startsAt!);

                      return Card(
                        child: ListTile(
                          title: Text(day.name),
                          subtitle: Text(startsAt),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => DayBrotherhoodsPage(
                                  daySlug: day.slug,
                                  dayName: day.name,
                                  mode: _mode,
                                  repository: widget.repository,
                                  config: widget.config,
                                  favoritesController: widget.favoritesController,
                                  simulatedClockController: widget.simulatedClockController,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemCount: days.length,
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
