import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../config/app_config.dart';
import '../../data/models/day_detail_model.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../live/status_style.dart';
import '../maps/mapbox_map_helpers.dart';
import '../planning/planning_controller.dart';
import '../time/simulated_clock_controller.dart';
import '../utils/color_utils.dart';
import '../widgets/app_scaffold_background.dart';
import '../widgets/missing_mapbox_token_card.dart';
import 'brotherhood_detail_page.dart';

class DayBrotherhoodsPage extends StatefulWidget {
  const DayBrotherhoodsPage({
    super.key,
    required this.daySlug,
    required this.dayName,
    required this.mode,
    required this.repository,
    required this.config,
    required this.favoritesController,
    required this.planningController,
    required this.simulatedClockController,
    this.initialTabIndex = 0,
    this.embedded = false,
  });

  final String daySlug;
  final String dayName;
  final String mode;
  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final PlanningController planningController;
  final SimulatedClockController simulatedClockController;
  final int initialTabIndex;
  final bool embedded;

  @override
  State<DayBrotherhoodsPage> createState() => _DayBrotherhoodsPageState();
}

class _DayBrotherhoodsPageState extends State<DayBrotherhoodsPage> {
  late int _selectedIndex;
  late Future<DayDetail> _future;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex.clamp(0, 3).toInt();
    _future = _load();
  }

  Future<DayDetail> _load() {
    return widget.repository.getDayDetail(
      citySlug: widget.config.citySlug,
      year: widget.config.editionYear,
      daySlug: widget.daySlug,
      mode: widget.mode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = AppScaffoldBackground(
      child: FutureBuilder<DayDetail>(
        future: _future,
        builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No se pudo cargar la jornada.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final detail = snapshot.data;
            if (detail == null || detail.processionEvents.isEmpty) {
              return const Center(
                child: Text('No hay datos cargados para esta jornada.'),
              );
            }

            return IndexedStack(
              index: _selectedIndex,
              children: [
                _DayScheduleTab(
                  citySlug: widget.config.citySlug,
                  year: widget.config.editionYear,
                  mode: widget.mode,
                  daySlug: widget.daySlug,
                  dayName: widget.dayName,
                  events: detail.processionEvents,
                  simulatedClockController: widget.simulatedClockController,
                  planningController: widget.planningController,
                ),
                _DayMapTab(events: detail.processionEvents),
                _DayBrotherhoodsTab(
                  citySlug: widget.config.citySlug,
                  year: widget.config.editionYear,
                  mode: widget.mode,
                  daySlug: widget.daySlug,
                  dayName: widget.dayName,
                  events: detail.processionEvents,
                  repository: widget.repository,
                  config: widget.config,
                  favoritesController: widget.favoritesController,
                  planningController: widget.planningController,
                  simulatedClockController: widget.simulatedClockController,
                ),
                _DayPlanningTab(
                  citySlug: widget.config.citySlug,
                  year: widget.config.editionYear,
                  mode: widget.mode,
                  daySlug: widget.daySlug,
                  planningController: widget.planningController,
                ),
              ],
            );
          },
      ),
    );

    final navBar = NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (value) => setState(() => _selectedIndex = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.schedule_outlined),
          selectedIcon: Icon(Icons.schedule),
          label: 'Horario',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Mapa',
        ),
        NavigationDestination(
          icon: Icon(Icons.church_outlined),
          selectedIcon: Icon(Icons.church),
          label: 'Hermandades',
        ),
        NavigationDestination(
          icon: Icon(Icons.star_outline),
          selectedIcon: Icon(Icons.star),
          label: 'Planning',
        ),
      ],
    );

    if (widget.embedded) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  widget.dayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: () => setState(() => _future = _load()),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          Expanded(child: content),
          navBar,
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dayName),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => setState(() => _future = _load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: content,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) =>
            setState(() => _selectedIndex = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Horario',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.church_outlined),
            selectedIcon: Icon(Icons.church),
            label: 'Hermandades',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: 'Planning',
          ),
        ],
      ),
    );
  }
}

enum _ScheduleViewMode { cards, table }

class _DayScheduleTab extends StatefulWidget {
  const _DayScheduleTab({
    required this.citySlug,
    required this.year,
    required this.mode,
    required this.daySlug,
    required this.dayName,
    required this.events,
    required this.simulatedClockController,
    required this.planningController,
  });

  final String citySlug;
  final int year;
  final String mode;
  final String daySlug;
  final String dayName;
  final List<DayProcessionEvent> events;
  final SimulatedClockController simulatedClockController;
  final PlanningController planningController;

  @override
  State<_DayScheduleTab> createState() => _DayScheduleTabState();
}

class _DayScheduleTabState extends State<_DayScheduleTab> {
  _ScheduleViewMode _mode = _ScheduleViewMode.cards;
  int _offsetMinutes = 0;

  DateTime _roundToNearestQuarterHour(DateTime source) {
    final totalMinutes = source.hour * 60 + source.minute;
    final rounded = ((totalMinutes + 7) ~/ 15) * 15;
    final dayStart = DateTime(source.year, source.month, source.day);
    return dayStart.add(Duration(minutes: rounded));
  }

  SchedulePoint? _currentPointAt(
    DayProcessionEvent event, {
    required DateTime at,
  }) {
    final timedPoints =
        event.schedulePoints
            .where((point) => point.plannedAt != null)
            .toList(growable: false)
          ..sort((a, b) => a.plannedAt!.compareTo(b.plannedAt!));

    if (timedPoints.isEmpty) {
      return null;
    }

    final first = timedPoints.first.plannedAt!;
    final last = timedPoints.last.plannedAt!;
    if (at.isBefore(first)) {
      return null;
    }

    SchedulePoint? latestPassed;
    for (final point in timedPoints) {
      if (point.plannedAt!.isAfter(at)) {
        break;
      }
      latestPassed = point;
    }

    final lastPointName = timedPoints.last.name.trim();
    if (at.isAfter(last) && _isTerminalPointName(lastPointName)) {
      return null;
    }

    return latestPassed;
  }

  bool _isTerminalPointName(String rawName) {
    final normalized = rawName.toLowerCase();
    return normalized.contains('recogida') ||
        normalized.contains('entrada') ||
        normalized.contains('templo') ||
        normalized.contains('basilica');
  }

  List<DateTime> _tableSlots(List<DayProcessionEvent> events) {
    final allTimes = events
        .expand((event) => event.schedulePoints)
        .map((point) => point.plannedAt)
        .whereType<DateTime>()
        .toList(growable: false);

    if (allTimes.isEmpty) {
      return const [];
    }

    allTimes.sort();
    final start = allTimes.first;
    final end = allTimes.last;

    final slots = <DateTime>[];
    var cursor = start;
    while (!cursor.isAfter(end)) {
      slots.add(cursor);
      cursor = cursor.add(const Duration(minutes: 30));
    }
    return slots;
  }

  List<DayProcessionEvent> _sortedEvents(List<DayProcessionEvent> events) {
    final sorted = [...events];
    sorted.sort((a, b) {
      DateTime? timeForCampanaOrFirst(DayProcessionEvent event) {
        DateTime? firstTimedPoint;
        DateTime? campanaTime;

        for (final point in event.schedulePoints) {
          final planned = point.plannedAt;
          if (planned == null) {
            continue;
          }

          firstTimedPoint ??= planned;

          final normalizedName = point.name.toLowerCase();
          if (campanaTime == null && normalizedName.contains('campana')) {
            campanaTime = planned;
          }
        }

        return campanaTime ?? firstTimedPoint;
      }

      final firstA = timeForCampanaOrFirst(a);
      final firstB = timeForCampanaOrFirst(b);

      if (firstA == null && firstB == null) {
        return a.brotherhoodName.compareTo(b.brotherhoodName);
      }
      if (firstA == null) {
        return 1;
      }
      if (firstB == null) {
        return -1;
      }
      final byTime = firstA.compareTo(firstB);
      if (byTime != 0) {
        return byTime;
      }
      return a.brotherhoodName.compareTo(b.brotherhoodName);
    });
    return sorted;
  }

  bool _hasAnyPlanningForEvent(DayProcessionEvent event) {
    final dayEntries = widget.planningController.entriesForDay(
      citySlug: widget.citySlug,
      year: widget.year,
      mode: widget.mode,
      daySlug: widget.daySlug,
    );
    return dayEntries.any(
      (entry) => entry.brotherhoodSlug == event.brotherhoodSlug,
    );
  }

  bool _isPlannedCell(DayProcessionEvent event, String pointName, DateTime at) {
    return widget.planningController.containsEntry(
      citySlug: widget.citySlug,
      year: widget.year,
      mode: widget.mode,
      daySlug: widget.daySlug,
      brotherhoodSlug: event.brotherhoodSlug,
      pointName: pointName,
      plannedAt: at,
    );
  }

  bool _isPlannedPoint(DayProcessionEvent event, SchedulePoint point) {
    final plannedAt = point.plannedAt;
    if (plannedAt == null) {
      return false;
    }
    return widget.planningController.containsEntry(
      citySlug: widget.citySlug,
      year: widget.year,
      mode: widget.mode,
      daySlug: widget.daySlug,
      brotherhoodSlug: event.brotherhoodSlug,
      pointName: point.name.trim().isEmpty ? 'Punto' : point.name.trim(),
      plannedAt: plannedAt,
    );
  }

  Future<void> _toggleCurrentCardPlanning(
    DayProcessionEvent event,
    DateTime at,
  ) async {
    final point = _currentPointAt(event, at: at);
    final plannedAt = point?.plannedAt;
    if (point == null || plannedAt == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay un punto planificable en esa hora para esta hermandad.',
          ),
        ),
      );
      return;
    }

    final entry = PlanningEntry(
      citySlug: widget.citySlug,
      year: widget.year,
      mode: widget.mode,
      daySlug: widget.daySlug,
      dayName: widget.dayName,
      brotherhoodSlug: event.brotherhoodSlug,
      brotherhoodName: event.brotherhoodName,
      brotherhoodColorHex: event.brotherhoodColorHex,
      pointName: point.name.trim().isEmpty ? 'Punto' : point.name.trim(),
      plannedAt: plannedAt,
      latitude: point.latitude,
      longitude: point.longitude,
    );
    await widget.planningController.toggle(entry);
  }

  Future<void> _openAgendaForEvent(DayProcessionEvent event) async {
    final timedPoints =
        event.schedulePoints
            .where((point) => point.plannedAt != null)
            .toList(growable: false)
          ..sort((a, b) => a.plannedAt!.compareTo(b.plannedAt!));

    if (timedPoints.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta hermandad no tiene puntos con hora para planificar.',
          ),
        ),
      );
      return;
    }

    final selected = await showModalBottomSheet<SchedulePoint>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  event.brotherhoodName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Selecciona punto y hora para tu planning',
                ),
              ),
              for (final point in timedPoints)
                ListTile(
                  leading: const Icon(Icons.event_note_outlined),
                  title: Text(
                    point.name.trim().isEmpty ? 'Punto' : point.name.trim(),
                  ),
                  subtitle: Text(DateFormat('HH:mm').format(point.plannedAt!)),
                  onTap: () => Navigator.of(context).pop(point),
                ),
            ],
          ),
        );
      },
    );

    if (selected == null || selected.plannedAt == null) {
      return;
    }

    final entry = PlanningEntry(
      citySlug: widget.citySlug,
      year: widget.year,
      mode: widget.mode,
      daySlug: widget.daySlug,
      dayName: widget.dayName,
      brotherhoodSlug: event.brotherhoodSlug,
      brotherhoodName: event.brotherhoodName,
      brotherhoodColorHex: event.brotherhoodColorHex,
      pointName: selected.name.trim().isEmpty ? 'Punto' : selected.name.trim(),
      plannedAt: selected.plannedAt!,
      latitude: selected.latitude,
      longitude: selected.longitude,
    );
    await widget.planningController.toggle(entry);
  }

  Future<void> _toggleSlotPlanning(
    DayProcessionEvent event,
    DateTime slot,
    String pointName,
    SchedulePoint? point,
  ) async {
    if (pointName.trim().isEmpty || pointName == '-') {
      return;
    }
    final entry = PlanningEntry(
      citySlug: widget.citySlug,
      year: widget.year,
      mode: widget.mode,
      daySlug: widget.daySlug,
      dayName: widget.dayName,
      brotherhoodSlug: event.brotherhoodSlug,
      brotherhoodName: event.brotherhoodName,
      brotherhoodColorHex: event.brotherhoodColorHex,
      pointName: pointName,
      plannedAt: slot,
      latitude: point?.latitude,
      longitude: point?.longitude,
    );
    await widget.planningController.toggle(entry);
  }

  @override
  Widget build(BuildContext context) {
    final sortedEvents = _sortedEvents(widget.events);
    final hasAnyTimedPoint = sortedEvents.any(
      (event) => event.schedulePoints.any((point) => point.plannedAt != null),
    );

    return ListenableBuilder(
      listenable: widget.planningController,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: widget.simulatedClockController,
          builder: (context, child) {
            final baseNow = _roundToNearestQuarterHour(
              widget.simulatedClockController.now,
            ).add(Duration(minutes: _offsetMinutes));
            final slots = _tableSlots(sortedEvents);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Row(
                  children: [
                    Text(
                      'Horario de la jornada',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    SegmentedButton<_ScheduleViewMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: _ScheduleViewMode.cards,
                          icon: Icon(Icons.view_agenda_outlined),
                          label: Text('Tarjetas'),
                        ),
                        ButtonSegment(
                          value: _ScheduleViewMode.table,
                          icon: Icon(Icons.table_chart_outlined),
                          label: Text('Tabla'),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (values) {
                        setState(() => _mode = values.first);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (!hasAnyTimedPoint)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Text(
                        'No hay puntos horarios cargados para esta jornada.',
                      ),
                    ),
                  )
                else if (_mode == _ScheduleViewMode.cards) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hora seleccionada: ${DateFormat('HH:mm').format(baseNow)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final delta in const [
                                -60,
                                -30,
                                -15,
                                15,
                                30,
                                60,
                              ])
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() => _offsetMinutes += delta);
                                  },
                                  child: Text(
                                    delta.isNegative ? '$delta' : '+$delta',
                                  ),
                                ),
                              TextButton(
                                onPressed: () {
                                  setState(() => _offsetMinutes = 0);
                                },
                                child: const Text('Ahora'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...sortedEvents.map((event) {
                    final style = statusStyleFor(event.status);
                    final currentPoint = _currentPointAt(event, at: baseNow);
                    final inPlanning =
                        currentPoint != null &&
                        _isPlannedPoint(event, currentPoint);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: parseHexColor(
                              event.brotherhoodColorHex,
                            ),
                            child: const Icon(
                              Icons.church_outlined,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(event.brotherhoodName),
                          subtitle: Text(
                            currentPoint == null
                                ? 'Templo'
                                : (currentPoint.name.trim().isEmpty
                                      ? 'Punto'
                                      : currentPoint.name.trim()),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: inPlanning
                                    ? 'Quitar del planning'
                                    : 'Añadir al planning',
                                onPressed: () =>
                                    _toggleCurrentCardPlanning(event, baseNow),
                                icon: Icon(
                                  inPlanning
                                      ? Icons.event_available
                                      : Icons.event_note_outlined,
                                ),
                                color: inPlanning
                                    ? const Color(0xFF8B1E3F)
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: style.background,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  style.label,
                                  style: TextStyle(
                                    color: style.foreground,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ] else ...[
                  Card(
                    child: Builder(
                      builder: (context) {
                        final baseStyle =
                            Theme.of(context).textTheme.bodyMedium ??
                            const TextStyle(fontSize: 14);
                        final textDirection = Directionality.of(context);
                        double maxNameWidth = 0;
                        for (final event in sortedEvents) {
                          final painter = TextPainter(
                            text: TextSpan(
                              text: event.brotherhoodName,
                              style: baseStyle,
                            ),
                            textDirection: textDirection,
                            maxLines: 1,
                          )..layout();
                          if (painter.width > maxNameWidth) {
                            maxNameWidth = painter.width;
                          }
                        }

                        final leftWidth = maxNameWidth + 72;
                        const cellWidth = 110.0;
                        const headerHeight = 44.0;
                        const rowHeight = 54.0;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: leftWidth,
                              child: Column(
                                children: [
                                  Container(
                                    height: headerHeight,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: const Text(
                                      'Hermandad',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  for (final event in sortedEvents)
                                    Container(
                                      height: rowHeight,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              event.brotherhoodName,
                                              style: baseStyle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip:
                                                _hasAnyPlanningForEvent(event)
                                                ? 'Quitar del planning'
                                                : 'Añadir al planning',
                                            onPressed: () =>
                                                _openAgendaForEvent(event),
                                            icon: Icon(
                                              _hasAnyPlanningForEvent(event)
                                                  ? Icons.event_available
                                                  : Icons.event_note_outlined,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                            color:
                                                _hasAnyPlanningForEvent(event)
                                                ? const Color(0xFF8B1E3F)
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        for (final slot in slots)
                                          Container(
                                            width: cellWidth,
                                            height: headerHeight,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              DateFormat('HH:mm').format(slot),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const Divider(height: 1),
                                    for (final event in sortedEvents)
                                      Row(
                                        children: [
                                          for (final slot in slots)
                                            Builder(
                                              builder: (context) {
                                                final point = _currentPointAt(
                                                  event,
                                                  at: slot,
                                                );
                                                final pointName = point == null
                                                    ? '-'
                                                    : (point.name.trim().isEmpty
                                                          ? 'Punto'
                                                          : point.name.trim());
                                                final planned = _isPlannedCell(
                                                  event,
                                                  pointName,
                                                  slot,
                                                );

                                                return InkWell(
                                                  onTap: pointName == '-'
                                                      ? null
                                                      : () =>
                                                            _toggleSlotPlanning(
                                                              event,
                                                              slot,
                                                              pointName,
                                                              point,
                                                            ),
                                                  child: Container(
                                                    width: cellWidth,
                                                    height: rowHeight,
                                                    alignment: Alignment.center,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: planned
                                                          ? const Color(
                                                              0xFFFFF4DB,
                                                            )
                                                          : null,
                                                      border: planned
                                                          ? Border.all(
                                                              color:
                                                                  const Color(
                                                                    0xFFC9983E,
                                                                  ),
                                                            )
                                                          : null,
                                                    ),
                                                    child: Text(
                                                      pointName,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                        ],
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
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _DayMapTab extends StatefulWidget {
  const _DayMapTab({required this.events});

  final List<DayProcessionEvent> events;

  @override
  State<_DayMapTab> createState() => _DayMapTabState();
}

class _DayMapTabState extends State<_DayMapTab> {
  MapboxMap? _map;
  PolylineAnnotationManager? _polylineManager;
  CircleAnnotationManager? _circleManager;

  List<_RouteLine> get _routeLines => widget.events
      .map(
        (event) => _RouteLine(
          points: event.routePoints
              .where((point) => point.isValid)
              .map(
                (point) => MapPoint(
                  latitude: point.latitude!,
                  longitude: point.longitude!,
                ),
              )
              .toList(growable: false),
          color: parseHexColor(event.brotherhoodColorHex),
        ),
      )
      .where((line) => line.points.length >= 2)
      .toList(growable: false);

  List<_ScheduleMarkerData> get _markers {
    final result = <_ScheduleMarkerData>[];
    for (final event in widget.events) {
      for (final point in event.schedulePoints) {
        if (!point.hasLocation) {
          continue;
        }
        result.add(
          _ScheduleMarkerData(
            location: MapPoint(
              latitude: point.latitude!,
              longitude: point.longitude!,
            ),
            brotherhoodName: event.brotherhoodName,
            pointName: point.name,
            plannedAt: point.plannedAt,
            color: parseHexColor(event.brotherhoodColorHex),
          ),
        );
      }
    }
    return result;
  }

  List<MapPoint> get _allPoints {
    final route = _routeLines.expand((line) => line.points);
    final markers = _markers.map((marker) => marker.location);
    return [...route, ...markers];
  }

  CameraOptions get _initialCamera =>
      cameraForPoints(_allPoints, fallbackZoom: 13.8);

  Future<void> _fitToBounds() async {
    await easeToPoints(_map, _allPoints, fallbackZoom: 13.8);
  }

  Future<void> _syncAnnotations() async {
    final polylineManager = _polylineManager;
    final circleManager = _circleManager;
    if (polylineManager == null || circleManager == null) {
      return;
    }

    await polylineManager.deleteAll();
    await circleManager.deleteAll();

    for (final line in _routeLines) {
      await polylineManager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: line.points
                .map((point) => point.toPoint().coordinates)
                .toList(growable: false),
          ),
          lineColor: line.color.toARGB32(),
          lineWidth: 4,
        ),
      );
    }

    for (final marker in _markers) {
      await circleManager.create(
        CircleAnnotationOptions(
          geometry: marker.location.toPoint(),
          circleColor: marker.color.toARGB32(),
          circleRadius: 5.5,
          circleStrokeColor: Colors.white.toARGB32(),
          circleStrokeWidth: 1.2,
        ),
      );
    }
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _map = mapboxMap;
    _polylineManager = await mapboxMap.annotations
        .createPolylineAnnotationManager();
    _circleManager = await mapboxMap.annotations
        .createCircleAnnotationManager();
    await _syncAnnotations();
  }

  @override
  void didUpdateWidget(covariant _DayMapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnnotations();
  }

  @override
  Widget build(BuildContext context) {
    final markers = _markers;
    final routeLines = _routeLines;

    return Stack(
      children: [
        if (kMapboxAccessToken.isEmpty)
          const MissingMapboxTokenCard()
        else
          MapWidget(
            key: const ValueKey('day-mapbox-map'),
            styleUri: kMapboxStyleUri,
            gestureRecognizers: kMapGestureRecognizers,
            cameraOptions: _initialCamera,
            onMapCreated: _onMapCreated,
          ),
        Positioned(
          right: 12,
          top: 12,
          child: FloatingActionButton.small(
            heroTag: 'day-map-fit-fab',
            onPressed: _fitToBounds,
            child: const Icon(Icons.center_focus_strong),
          ),
        ),
        if (markers.isEmpty && routeLines.isEmpty)
          const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text('No hay coordenadas cargadas para esta jornada.'),
              ),
            ),
          ),
      ],
    );
  }
}

class _DayBrotherhoodsTab extends StatelessWidget {
  const _DayBrotherhoodsTab({
    required this.citySlug,
    required this.year,
    required this.mode,
    required this.daySlug,
    required this.dayName,
    required this.events,
    required this.repository,
    required this.config,
    required this.favoritesController,
    required this.planningController,
    required this.simulatedClockController,
  });

  final String citySlug;
  final int year;
  final String mode;
  final String daySlug;
  final String dayName;
  final List<DayProcessionEvent> events;
  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final PlanningController planningController;
  final SimulatedClockController simulatedClockController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: planningController,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: favoritesController,
          builder: (context, child) {
            final dayEntries = planningController.entriesForDay(
              citySlug: citySlug,
              year: year,
              mode: mode,
              daySlug: daySlug,
            );

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemBuilder: (context, index) {
                final event = events[index];
                final isFavorite = favoritesController.isFavorite(
                  event.brotherhoodSlug,
                );
                final hasPlanning = dayEntries.any(
                  (entry) => entry.brotherhoodSlug == event.brotherhoodSlug,
                );
                final statusStyle = statusStyleFor(event.status);

                return Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.church_outlined,
                      color: isFavorite ? const Color(0xFFC9983E) : null,
                    ),
                    title: Text(event.brotherhoodName),
                    subtitle: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(statusStyle.label),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: parseHexColor(event.brotherhoodColorHex),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: hasPlanning
                              ? 'Editar planning'
                              : 'Añadir al planning',
                          onPressed: () async {
                            final timedPoints =
                                event.schedulePoints
                                    .where((point) => point.plannedAt != null)
                                    .toList(growable: false)
                                  ..sort(
                                    (a, b) =>
                                        a.plannedAt!.compareTo(b.plannedAt!),
                                  );

                            if (timedPoints.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Esta hermandad no tiene puntos con hora para planificar.',
                                  ),
                                ),
                              );
                              return;
                            }

                            final selected =
                                await showModalBottomSheet<SchedulePoint>(
                                  context: context,
                                  showDragHandle: true,
                                  builder: (context) {
                                    return SafeArea(
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          ListTile(
                                            title: Text(
                                              event.brotherhoodName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            subtitle: const Text(
                                              'Selecciona punto y hora para tu planning',
                                            ),
                                          ),
                                          for (final point in timedPoints)
                                            ListTile(
                                              leading: const Icon(
                                                Icons.event_note_outlined,
                                              ),
                                              title: Text(
                                                point.name.trim().isEmpty
                                                    ? 'Punto'
                                                    : point.name.trim(),
                                              ),
                                              subtitle: Text(
                                                DateFormat(
                                                  'HH:mm',
                                                ).format(point.plannedAt!),
                                              ),
                                              onTap: () => Navigator.of(
                                                context,
                                              ).pop(point),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );

                            if (selected == null ||
                                selected.plannedAt == null) {
                              return;
                            }

                            final entry = PlanningEntry(
                              citySlug: citySlug,
                              year: year,
                              mode: mode,
                              daySlug: daySlug,
                              dayName: dayName,
                              brotherhoodSlug: event.brotherhoodSlug,
                              brotherhoodName: event.brotherhoodName,
                              brotherhoodColorHex: event.brotherhoodColorHex,
                              pointName: selected.name.trim().isEmpty
                                  ? 'Punto'
                                  : selected.name.trim(),
                              plannedAt: selected.plannedAt!,
                              latitude: selected.latitude,
                              longitude: selected.longitude,
                            );
                            await planningController.toggle(entry);
                          },
                          icon: Icon(
                            hasPlanning
                                ? Icons.event_available
                                : Icons.event_note_outlined,
                          ),
                          color: hasPlanning ? const Color(0xFF8B1E3F) : null,
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: event.brotherhoodSlug.isEmpty
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => BrotherhoodDetailPage(
                                  brotherhoodSlug: event.brotherhoodSlug,
                                  title: event.brotherhoodName,
                                  repository: repository,
                                  config: config,
                                  favoritesController: favoritesController,
                                  simulatedClockController:
                                      simulatedClockController,
                                ),
                              ),
                            );
                          },
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemCount: events.length,
            );
          },
        );
      },
    );
  }
}

enum _DayPlanningViewMode { list, map }

class _DayPlanningTab extends StatefulWidget {
  const _DayPlanningTab({
    required this.citySlug,
    required this.year,
    required this.mode,
    required this.daySlug,
    required this.planningController,
  });

  final String citySlug;
  final int year;
  final String mode;
  final String daySlug;
  final PlanningController planningController;

  @override
  State<_DayPlanningTab> createState() => _DayPlanningTabState();
}

class _DayPlanningTabState extends State<_DayPlanningTab> {
  MapboxMap? _map;
  CircleAnnotationManager? _circleManager;
  _DayPlanningViewMode _viewMode = _DayPlanningViewMode.list;
  String? _focusedEntryId;

  Future<void> _focusEntryOnMap(PlanningEntry entry) async {
    setState(() {
      _viewMode = _DayPlanningViewMode.map;
      _focusedEntryId = entry.id;
    });

    if (!entry.hasLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este punto no tiene coordenadas para mostrar en mapa.',
          ),
        ),
      );
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _map?.easeTo(
        CameraOptions(
          center: Point(
            coordinates: Position(entry.longitude!, entry.latitude!),
          ),
          zoom: 16.4,
        ),
        MapAnimationOptions(duration: 850),
      );
    });
  }

  Future<void> _fitToEntries(List<PlanningEntry> entries) async {
    final points = entries
        .where((entry) => entry.hasLocation)
        .map(
          (entry) =>
              MapPoint(latitude: entry.latitude!, longitude: entry.longitude!),
        )
        .toList(growable: false);
    await easeToPoints(_map, points, fallbackZoom: 13.8);
  }

  Future<void> _syncPlanningMarkers(List<PlanningEntry> withLocation) async {
    final circleManager = _circleManager;
    if (circleManager == null) {
      return;
    }

    await circleManager.deleteAll();
    for (final entry in withLocation) {
      final isFocused = _focusedEntryId == entry.id;
      await circleManager.create(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(entry.longitude!, entry.latitude!),
          ),
          circleColor: const Color(0xFF8B1E3F).toARGB32(),
          circleRadius: isFocused ? 8 : 6,
          circleStrokeColor: Colors.white.toARGB32(),
          circleStrokeWidth: 1.6,
        ),
      );
    }
  }

  Future<void> _onPlanningMapCreated(MapboxMap mapboxMap) async {
    _map = mapboxMap;
    _circleManager = await mapboxMap.annotations
        .createCircleAnnotationManager();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.planningController,
      builder: (context, child) {
        final entries = widget.planningController.entriesForDay(
          citySlug: widget.citySlug,
          year: widget.year,
          mode: widget.mode,
          daySlug: widget.daySlug,
        )..sort((a, b) => a.plannedAt.compareTo(b.plannedAt));

        if (entries.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No tienes puntos en planning para esta jornada. Añadelos desde Horario o Hermandades con el icono de agenda.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final withLocation = entries
            .where((entry) => entry.hasLocation)
            .toList(growable: false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _syncPlanningMarkers(withLocation);
        });
        PlanningEntry? focusedEntry;
        int focusedIndex = -1;
        if (withLocation.isNotEmpty) {
          for (var i = 0; i < withLocation.length; i++) {
            final entry = withLocation[i];
            if (entry.id == _focusedEntryId) {
              focusedEntry = entry;
              focusedIndex = i;
              break;
            }
          }
          if (focusedEntry == null) {
            focusedEntry = withLocation.first;
            focusedIndex = 0;
          }
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Planning del dia',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  SegmentedButton<_DayPlanningViewMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: _DayPlanningViewMode.list,
                        icon: Icon(Icons.view_list_outlined),
                        label: Text('Listado'),
                      ),
                      ButtonSegment(
                        value: _DayPlanningViewMode.map,
                        icon: Icon(Icons.map_outlined),
                        label: Text('Mapa'),
                      ),
                    ],
                    selected: {_viewMode},
                    onSelectionChanged: (values) {
                      setState(() => _viewMode = values.first);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: _viewMode == _DayPlanningViewMode.list
                  ? ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final isFocused = _focusedEntryId == entry.id;
                        return Card(
                          color: isFocused ? const Color(0xFFFFF4DB) : null,
                          child: ListTile(
                            leading: Icon(
                              entry.hasLocation
                                  ? Icons.event_available
                                  : Icons.event_note_outlined,
                              color: const Color(0xFF8B1E3F),
                            ),
                            title: Text(entry.brotherhoodName),
                            subtitle: Text(
                              '${entry.pointName} · ${DateFormat('HH:mm').format(entry.plannedAt)}',
                            ),
                            trailing: IconButton(
                              onPressed: () =>
                                  widget.planningController.toggle(entry),
                              icon: const Icon(Icons.delete_outline),
                            ),
                            onTap: () => _focusEntryOnMap(entry),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemCount: entries.length,
                    )
                  : Stack(
                      children: [
                        if (kMapboxAccessToken.isEmpty)
                          const MissingMapboxTokenCard()
                        else
                          MapWidget(
                            key: const ValueKey('day-planning-mapbox-map'),
                            styleUri: kMapboxStyleUri,
                            gestureRecognizers: kMapGestureRecognizers,
                            cameraOptions: CameraOptions(
                              center: defaultSevillePoint().toPoint(),
                              zoom: 13.8,
                            ),
                            onMapCreated: _onPlanningMapCreated,
                          ),
                        if (withLocation.isEmpty)
                          const Center(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(14),
                                child: Text(
                                  'No hay puntos con coordenadas en tu planning de hoy.',
                                ),
                              ),
                            ),
                          ),
                        if (withLocation.isNotEmpty)
                          Positioned(
                            right: 12,
                            top: 12,
                            child: FloatingActionButton.small(
                              heroTag: 'day-planning-map-fit-fab',
                              onPressed: () => _fitToEntries(withLocation),
                              child: const Icon(Icons.center_focus_strong),
                            ),
                          ),
                        if (focusedEntry != null)
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.event_available,
                                  color: Color(0xFF8B1E3F),
                                ),
                                title: Text(focusedEntry.brotherhoodName),
                                subtitle: Text(
                                  '${focusedEntry.pointName} · ${DateFormat('HH:mm').format(focusedEntry.plannedAt)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Punto anterior',
                                      onPressed: focusedIndex > 0
                                          ? () => _focusEntryOnMap(
                                              withLocation[focusedIndex - 1],
                                            )
                                          : null,
                                      icon: const Icon(Icons.chevron_left),
                                    ),
                                    IconButton(
                                      tooltip: 'Punto siguiente',
                                      onPressed:
                                          focusedIndex >= 0 &&
                                              focusedIndex <
                                                  withLocation.length - 1
                                          ? () => _focusEntryOnMap(
                                              withLocation[focusedIndex + 1],
                                            )
                                          : null,
                                      icon: const Icon(Icons.chevron_right),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _RouteLine {
  const _RouteLine({required this.points, required this.color});

  final List<MapPoint> points;
  final Color color;
}

class _ScheduleMarkerData {
  const _ScheduleMarkerData({
    required this.location,
    required this.brotherhoodName,
    required this.pointName,
    required this.plannedAt,
    required this.color,
  });

  final MapPoint location;
  final String brotherhoodName;
  final String pointName;
  final DateTime? plannedAt;
  final Color color;

  String get hourLabel =>
      plannedAt == null ? '--:--' : DateFormat('HH:mm').format(plannedAt!);
}
