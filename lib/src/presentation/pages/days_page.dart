import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/app_config.dart';
import '../../data/models/day_models.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../mode/mode_controller.dart';
import '../planning/planning_controller.dart';
import '../time/simulated_clock_controller.dart';
import '../widgets/app_scaffold_background.dart';
import '../widgets/card_list_tile.dart';
import 'day_brotherhoods_page.dart';

class DaysPage extends StatefulWidget {
  const DaysPage({
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
  State<DaysPage> createState() => _DaysPageState();
}

class _DaysPageState extends State<DaysPage> {
  late String _mode;
  late Future<List<DayIndexItem>> _daysFuture;
  String? _selectedDaySlug;

  @override
  void initState() {
    super.initState();
    _mode = widget.modeController.mode;
    widget.modeController.addListener(_onModeChanged);
    _daysFuture = _loadDays();
  }

  @override
  void dispose() {
    widget.modeController.removeListener(_onModeChanged);
    super.dispose();
  }

  Future<List<DayIndexItem>> _loadDays() {
    return widget.repository.getDays(
      citySlug: widget.config.citySlug,
      year: widget.config.editionYear,
      mode: _mode,
    );
  }

  void _onModeChanged() {
    final mode = widget.modeController.mode;
    if (mode == _mode) {
      return;
    }
    setState(() {
      _mode = mode;
      _selectedDaySlug = null;
      _daysFuture = _loadDays();
    });
  }

  DayIndexItem? _selectedDayFor(List<DayIndexItem> days) {
    if (days.isEmpty) {
      return null;
    }
    final slug = _selectedDaySlug;
    if (slug == null) {
      return days.first;
    }
    for (final day in days) {
      if (day.slug == slug) {
        return day;
      }
    }
    return days.first;
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
                    return const Center(
                      child: Text('Sin jornadas para este modo.'),
                    );
                  }

                  final media = MediaQuery.of(context);
                  final isTabletLandscape =
                      media.orientation == Orientation.landscape &&
                      media.size.width >= 1000 &&
                      media.size.height >= 600;
                  final selectedDay = _selectedDayFor(days);

                  if (isTabletLandscape) {
                    return Row(
                      children: [
                        SizedBox(
                          width: 360,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 4, 12, 24),
                            itemBuilder: (context, index) {
                              final day = days[index];
                              return _DayTile(
                                day: day,
                                isSelected: day.slug == selectedDay?.slug,
                                onTap: () {
                                  setState(() => _selectedDaySlug = day.slug);
                                },
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemCount: days.length,
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 4, 20, 24),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: selectedDay == null
                                  ? const Center(
                                      child: Text('Selecciona una jornada.'),
                                    )
                                  : DayBrotherhoodsPage(
                                      daySlug: selectedDay.slug,
                                      dayName: selectedDay.name,
                                      mode: _mode,
                                      repository: widget.repository,
                                      config: widget.config,
                                      favoritesController:
                                          widget.favoritesController,
                                      planningController:
                                          widget.planningController,
                                      simulatedClockController:
                                          widget.simulatedClockController,
                                      embedded: true,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemBuilder: (context, index) {
                      final day = days[index];

                      return _DayTile(
                        day: day,
                        isSelected: false,
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
                                planningController: widget.planningController,
                                simulatedClockController:
                                    widget.simulatedClockController,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
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

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final DayIndexItem day;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final startsAt = day.startsAt == null
        ? 'Sin hora'
        : DateFormat('EEEE d, HH:mm').format(day.startsAt!);

    return CardListTile(
      color: isSelected ? const Color(0xFFFFF4DB) : null,
      selected: isSelected,
      title: Text(day.name),
      subtitle: Text(startsAt),
      trailing: Icon(isSelected ? Icons.chevron_left : Icons.chevron_right),
      onTap: onTap,
    );
  }
}
