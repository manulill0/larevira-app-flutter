import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../config/app_config.dart';
import '../../data/models/day_detail_model.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../../live/live_update_controller.dart';
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
    required this.liveUpdateController,
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
  final LiveUpdateController liveUpdateController;
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
  late _DayTimeController _dayTimeController;
  StreamSubscription<ProcessionStatusUpdate>? _updateSubscription;
  bool _refreshInFlight = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex.clamp(0, 3).toInt();
    _future = _load();
    _dayTimeController = _DayTimeController(widget.simulatedClockController);
    _bindLiveUpdates();
  }

  @override
  void didUpdateWidget(covariant DayBrotherhoodsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.simulatedClockController != widget.simulatedClockController) {
      _dayTimeController.dispose();
      _dayTimeController = _DayTimeController(widget.simulatedClockController);
    }
    if (oldWidget.liveUpdateController != widget.liveUpdateController) {
      _updateSubscription?.cancel();
      _bindLiveUpdates();
    }
    if (oldWidget.daySlug != widget.daySlug || oldWidget.mode != widget.mode) {
      setState(() {
        _selectedIndex = 0;
        _future = _load();
        _dayTimeController.resetOffset();
      });
    }
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    _dayTimeController.dispose();
    super.dispose();
  }

  Future<DayDetail> _load({bool preferRemote = false}) {
    return widget.repository.getDayDetail(
      citySlug: widget.config.citySlug,
      year: widget.config.editionYear,
      daySlug: widget.daySlug,
      mode: widget.mode,
      preferRemote: preferRemote,
    );
  }

  void _bindLiveUpdates() {
    _updateSubscription = widget.liveUpdateController.updates.listen((update) {
      if (!mounted) {
        return;
      }
      if (!update.matchesDay(
        citySlug: widget.config.citySlug,
        year: widget.config.editionYear,
        daySlug: widget.daySlug,
      )) {
        return;
      }
      _refreshNow();
    });
  }

  Future<void> _refreshNow() async {
    if (_refreshInFlight) {
      return;
    }

    _refreshInFlight = true;

    try {
      final detail = await widget.repository.refreshDayDetail(
        citySlug: widget.config.citySlug,
        year: widget.config.editionYear,
        daySlug: widget.daySlug,
        mode: widget.mode,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _future = Future<DayDetail>.value(detail);
      });
    } catch (_) {
      // Conservamos los datos visibles si no hay red.
    } finally {
      _refreshInFlight = false;
    }
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

          _dayTimeController.syncBaseDayFromEvents(detail.processionEvents);

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
                timeController: _dayTimeController,
                planningController: widget.planningController,
              ),
              _DayMapTab(
                events: detail.processionEvents,
                timeController: _dayTimeController,
              ),
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

    if (widget.embedded) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              children: [
                Row(
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
                      onPressed: () {
                        _refreshNow();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        icon: Icon(Icons.schedule_outlined),
                        label: Text('Horario'),
                      ),
                      ButtonSegment(
                        value: 1,
                        icon: Icon(Icons.map_outlined),
                        label: Text('Mapa'),
                      ),
                      ButtonSegment(
                        value: 2,
                        icon: Icon(Icons.church_outlined),
                        label: Text('Hermandades'),
                      ),
                      ButtonSegment(
                        value: 3,
                        icon: Icon(Icons.star_outline),
                        label: Text('Planning'),
                      ),
                    ],
                    selected: {_selectedIndex},
                    onSelectionChanged: (value) {
                      setState(() => _selectedIndex = value.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dayName),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () {
              _refreshNow();
            },
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

class _DayTimeController extends ChangeNotifier {
  _DayTimeController(this._simulatedClockController) {
    _simulatedClockController.addListener(_handleClockChanged);
  }

  final SimulatedClockController _simulatedClockController;
  int _offsetMinutes = 0;
  DateTime? _baseDay;

  int get offsetMinutes => _offsetMinutes;

  DateTime get selectedTime {
    final source = _simulatedClockController.now;
    final totalMinutes = source.hour * 60 + source.minute;
    final rounded = ((totalMinutes + 7) ~/ 15) * 15;
    final baseDay = _baseDay ?? DateTime(source.year, source.month, source.day);
    final dayStart = DateTime(baseDay.year, baseDay.month, baseDay.day);
    return dayStart.add(Duration(minutes: rounded + _offsetMinutes));
  }

  void syncBaseDayFromEvents(List<DayProcessionEvent> events) {
    DateTime? nextBaseDay;

    for (final event in events) {
      for (final point in event.schedulePoints) {
        final plannedAt = point.plannedAt;
        if (plannedAt == null) {
          continue;
        }

        final candidate = DateTime(
          plannedAt.year,
          plannedAt.month,
          plannedAt.day,
        );
        if (nextBaseDay == null || candidate.isBefore(nextBaseDay)) {
          nextBaseDay = candidate;
        }
      }
    }

    _baseDay = nextBaseDay;
  }

  void addOffset(int minutes) {
    if (minutes == 0) {
      return;
    }
    _offsetMinutes += minutes;
    notifyListeners();
  }

  void resetOffset() {
    if (_offsetMinutes == 0) {
      return;
    }
    _offsetMinutes = 0;
    notifyListeners();
  }

  void _handleClockChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _simulatedClockController.removeListener(_handleClockChanged);
    super.dispose();
  }
}

class _DayTimeSelectorCard extends StatelessWidget {
  const _DayTimeSelectorCard({
    required this.timeController,
    this.compact = false,
    this.framed = true,
  });

  final _DayTimeController timeController;
  final bool compact;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final selectedTime = timeController.selectedTime;
    final controls = compact
        ? Row(
            children: [
              Expanded(
                child: _TimeIconButton(
                  icon: Icons.fast_rewind,
                  tooltip: 'Restar 60 minutos',
                  onPressed: () => timeController.addOffset(-60),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _TimeIconButton(
                  icon: Icons.keyboard_double_arrow_left,
                  tooltip: 'Restar 30 minutos',
                  onPressed: () => timeController.addOffset(-30),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _TimeIconButton(
                  icon: Icons.chevron_left,
                  tooltip: 'Restar 15 minutos',
                  onPressed: () => timeController.addOffset(-15),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: _NowTimeButton(onPressed: timeController.resetOffset),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _TimeIconButton(
                  icon: Icons.chevron_right,
                  tooltip: 'Sumar 15 minutos',
                  onPressed: () => timeController.addOffset(15),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _TimeIconButton(
                  icon: Icons.keyboard_double_arrow_right,
                  tooltip: 'Sumar 30 minutos',
                  onPressed: () => timeController.addOffset(30),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _TimeIconButton(
                  icon: Icons.fast_forward,
                  tooltip: 'Sumar 60 minutos',
                  onPressed: () => timeController.addOffset(60),
                ),
              ),
            ],
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TimeIconButton(
                  icon: Icons.fast_rewind,
                  tooltip: 'Restar 60 minutos',
                  onPressed: () => timeController.addOffset(-60),
                ),
                const SizedBox(width: 8),
                _TimeIconButton(
                  icon: Icons.keyboard_double_arrow_left,
                  tooltip: 'Restar 30 minutos',
                  onPressed: () => timeController.addOffset(-30),
                ),
                const SizedBox(width: 8),
                _TimeIconButton(
                  icon: Icons.chevron_left,
                  tooltip: 'Restar 15 minutos',
                  onPressed: () => timeController.addOffset(-15),
                ),
                const SizedBox(width: 8),
                _NowTimeButton(onPressed: timeController.resetOffset),
                const SizedBox(width: 8),
                _TimeIconButton(
                  icon: Icons.chevron_right,
                  tooltip: 'Sumar 15 minutos',
                  onPressed: () => timeController.addOffset(15),
                ),
                const SizedBox(width: 8),
                _TimeIconButton(
                  icon: Icons.keyboard_double_arrow_right,
                  tooltip: 'Sumar 30 minutos',
                  onPressed: () => timeController.addOffset(30),
                ),
                const SizedBox(width: 8),
                _TimeIconButton(
                  icon: Icons.fast_forward,
                  tooltip: 'Sumar 60 minutos',
                  onPressed: () => timeController.addOffset(60),
                ),
              ],
            ),
          );
    final content = Padding(
      padding: EdgeInsets.all(compact ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hora seleccionada: ${DateFormat('HH:mm').format(selectedTime)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: compact ? 13 : 14,
            ),
          ),
          SizedBox(height: compact ? 6 : 8),
          controls,
        ],
      ),
    );

    if (!framed) {
      return content;
    }

    return Card(child: content);
  }
}

class _TimeIconButton extends StatelessWidget {
  const _TimeIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          minimumSize: const ui.Size(44, 44),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _NowTimeButton extends StatelessWidget {
  const _NowTimeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity.compact,
        minimumSize: const ui.Size(72, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: const Text('Ahora'),
    );
  }
}

class _DayScheduleTab extends StatefulWidget {
  const _DayScheduleTab({
    required this.citySlug,
    required this.year,
    required this.mode,
    required this.daySlug,
    required this.dayName,
    required this.events,
    required this.timeController,
    required this.planningController,
  });

  final String citySlug;
  final int year;
  final String mode;
  final String daySlug;
  final String dayName;
  final List<DayProcessionEvent> events;
  final _DayTimeController timeController;
  final PlanningController planningController;

  @override
  State<_DayScheduleTab> createState() => _DayScheduleTabState();
}

class _DayScheduleTabState extends State<_DayScheduleTab> {
  _ScheduleViewMode _mode = _ScheduleViewMode.cards;

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
          listenable: widget.timeController,
          builder: (context, child) {
            final baseNow = widget.timeController.selectedTime;
            final slots = _tableSlots(sortedEvents);
            final listContent = ListView(
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

            if (!hasAnyTimedPoint) {
              return listContent;
            }

            return Column(
              children: [
                Expanded(child: listContent),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: _DayTimeSelectorCard(
                    timeController: widget.timeController,
                    compact: true,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DayMapTab extends StatefulWidget {
  const _DayMapTab({required this.events, required this.timeController});

  final List<DayProcessionEvent> events;
  final _DayTimeController timeController;

  @override
  State<_DayMapTab> createState() => _DayMapTabState();
}

class _DayMapTabState extends State<_DayMapTab> {
  MapboxMap? _map;
  PolylineAnnotationManager? _polylineManager;
  CircleAnnotationManager? _circleManager;
  Cancelable? _circleTapCancelable;
  Timer? _pointCalloutTimer;
  String? _lastAnnotationSignature;
  String _selectedBrotherhoodSlug = 'all';
  bool _showLegend = false;
  bool _followUserLocation = false;
  final ValueNotifier<_MapPointCallout?> _pointCallout = ValueNotifier(null);

  Future<bool> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      return true;
    }

    final requested = await Permission.locationWhenInUse.request();

    return requested.isGranted;
  }

  Future<bool> _enableUserLocation() async {
    final map = _map;
    if (map == null) {
      return false;
    }

    final granted = await _requestLocationPermission();
    if (!granted) {
      if (mounted) {
        setState(() {
          _followUserLocation = false;
        });
      }

      _pointCallout.value = const _MapPointCallout(
        label: 'Activa la ubicacion para mostrar tu posicion en el mapa.',
        x: 160,
        y: 92,
        latitude: null,
        longitude: null,
      );
      _pointCalloutTimer?.cancel();
      _pointCalloutTimer = Timer(const Duration(seconds: 5), () {
        _pointCallout.value = null;
      });

      return false;
    }

    try {
      await map.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          showAccuracyRing: true,
          puckBearingEnabled: true,
          puckBearing: PuckBearing.HEADING,
        ),
      );
      return true;
    } catch (_) {
      // If the OS permission is missing, Mapbox will reject the location layer.
      // The map should keep working without blocking the rest of the UI.
      return false;
    }
  }

  Future<void> _centerOnUserLocation() async {
    final enabled = await _enableUserLocation();
    if (!enabled || !mounted) {
      return;
    }

    setState(() {
      _followUserLocation = true;
    });
  }

  Future<void> _showPointCallout(Map<String, Object> data) async {
    final map = _map;
    if (map == null) {
      return;
    }

    final brotherhood = (data['brotherhood'] ?? 'Hermandad').toString();
    final location = (data['location'] ?? 'Punto de paso').toString();
    final lat = (data['lat'] as num?)?.toDouble();
    final lng = (data['lng'] as num?)?.toDouble();

    if (lat == null || lng == null) {
      return;
    }

    try {
      final pixel = await map.pixelForCoordinate(
        Point(coordinates: Position(lng, lat)),
      );

      _pointCallout.value = _MapPointCallout(
        label: '$brotherhood · $location',
        x: pixel.x,
        y: pixel.y,
        latitude: lat,
        longitude: lng,
      );
      _pointCalloutTimer?.cancel();
      _pointCalloutTimer = Timer(const Duration(seconds: 5), () {
        _pointCallout.value = null;
      });
    } catch (_) {
      // Ignore temporary map projection failures.
    }
  }

  Future<void> _refreshPointCalloutPosition() async {
    final map = _map;
    final callout = _pointCallout.value;
    if (map == null || callout == null) {
      return;
    }

    final lat = callout.latitude;
    final lng = callout.longitude;
    if (lat == null || lng == null) {
      return;
    }

    try {
      final pixel = await map.pixelForCoordinate(
        Point(coordinates: Position(lng, lat)),
      );

      _pointCallout.value = _MapPointCallout(
        label: callout.label,
        x: pixel.x,
        y: pixel.y,
        latitude: lat,
        longitude: lng,
      );
    } catch (_) {
      // Ignore temporary map projection failures while interacting with the map.
    }
  }

  int _nearestRouteIndexFrom(
    List<MapPoint> route,
    MapPoint target,
    int startIndex,
  ) {
    var bestIndex = startIndex;
    var bestDistance = double.infinity;

    for (var i = startIndex; i < route.length; i++) {
      final latDiff = route[i].latitude - target.latitude;
      final lngDiff = route[i].longitude - target.longitude;
      final sqDistance = (latDiff * latDiff) + (lngDiff * lngDiff);
      if (sqDistance < bestDistance) {
        bestDistance = sqDistance;
        bestIndex = i;
      }
    }

    return bestIndex;
  }

  double? _routeIndexAtTime(List<_TimedRoutePoint> points, DateTime at) {
    if (points.isEmpty) {
      return null;
    }
    if (at.isBefore(points.first.time)) {
      return null;
    }
    if (!at.isBefore(points.last.time)) {
      return points.last.routeIndex.toDouble();
    }

    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (at.isBefore(a.time) || at.isAfter(b.time)) {
        continue;
      }

      final totalMs = b.time.difference(a.time).inMilliseconds;
      if (totalMs <= 0) {
        return b.routeIndex.toDouble();
      }
      final partMs = at.difference(a.time).inMilliseconds.clamp(0, totalMs);
      final ratio = partMs / totalMs;
      return a.routeIndex + ((b.routeIndex - a.routeIndex) * ratio);
    }

    return points.last.routeIndex.toDouble();
  }

  MapPoint _pointAtIndex(List<MapPoint> route, double index) {
    final lastIndex = route.length - 1;
    if (lastIndex <= 0) {
      return route.first;
    }

    final clamped = index.clamp(0, lastIndex.toDouble());
    final low = clamped.floor();
    final high = clamped.ceil();
    if (low == high) {
      return route[low];
    }

    final ratio = clamped - low;
    final start = route[low];
    final end = route[high];
    return MapPoint(
      latitude: start.latitude + ((end.latitude - start.latitude) * ratio),
      longitude: start.longitude + ((end.longitude - start.longitude) * ratio),
    );
  }

  List<MapPoint> _sliceRoute(List<MapPoint> route, double from, double to) {
    if (route.isEmpty) {
      return const [];
    }

    var start = from;
    var end = to;
    if (end < start) {
      final temp = start;
      start = end;
      end = temp;
    }

    final startPoint = _pointAtIndex(route, start);
    final endPoint = _pointAtIndex(route, end);
    final startFloor = start.floor();
    final endCeil = end.ceil();

    final points = <MapPoint>[startPoint];
    for (var i = startFloor + 1; i < endCeil; i++) {
      if (i >= 0 && i < route.length) {
        points.add(route[i]);
      }
    }
    points.add(endPoint);

    if (points.length == 1 && route.length >= 2) {
      final idx = startFloor.clamp(0, route.length - 1);
      final neighbor = (idx + 1).clamp(0, route.length - 1);
      if (neighbor != idx) {
        points.add(route[neighbor]);
      }
    }

    return points;
  }

  Iterable<DayProcessionEvent> get _filteredEvents sync* {
    for (final event in widget.events) {
      if (_selectedBrotherhoodSlug != 'all' &&
          event.brotherhoodSlug != _selectedBrotherhoodSlug) {
        continue;
      }
      yield event;
    }
  }

  bool _isEventVisibleAt(DayProcessionEvent event, DateTime selectedTime) {
    final timedSchedule =
        event.schedulePoints
            .where((point) => point.hasLocation && point.plannedAt != null)
            .toList(growable: false)
          ..sort((a, b) => a.plannedAt!.compareTo(b.plannedAt!));

    if (timedSchedule.isEmpty) {
      return true;
    }

    final startsAt = timedSchedule.first.plannedAt!;
    final endsAt = timedSchedule.last.plannedAt!.add(
      Duration(minutes: (event.passDurationMinutes ?? 0).clamp(0, 240)),
    );

    return !selectedTime.isBefore(startsAt) && !selectedTime.isAfter(endsAt);
  }

  List<_VisibleRoute> _visibleRoutes(DateTime selectedTime) {
    return _filteredEvents
        .where((event) => _isEventVisibleAt(event, selectedTime))
        .map(
          (event) => _VisibleRoute(
            color: parseHexColor(event.brotherhoodColorHex),
            points: event.routePoints
                .where((point) => point.isValid)
                .map(
                  (point) => MapPoint(
                    latitude: point.latitude!,
                    longitude: point.longitude!,
                  ),
                )
                .toList(growable: false),
          ),
        )
        .where((route) => route.points.length >= 2)
        .toList(growable: false);
  }

  _VisibleRoute? _officialCourseRoute(DateTime selectedTime) {
    for (final event in _filteredEvents) {
      if (!_isEventVisibleAt(event, selectedTime)) {
        continue;
      }

      for (final section in event.routeSections) {
        if (!isOfficialCourseSectionName(section.name)) {
          continue;
        }

        final points = section.points
            .where((point) => point.hasLocation)
            .map(
              (point) => MapPoint(
                latitude: point.latitude!,
                longitude: point.longitude!,
              ),
            )
            .toList(growable: false);

        if (points.length < 2) {
          continue;
        }

        return _VisibleRoute(
          color: parseKmlAbgrColor(
            section.lineColorKml,
            fallback: kOfficialCourseFallbackColor,
          ),
          points: points,
        );
      }
    }

    return null;
  }

  Color _officialCourseLegendColor() {
    for (final event in _filteredEvents) {
      for (final section in event.routeSections) {
        if (!isOfficialCourseSectionName(section.name)) {
          continue;
        }

        return parseKmlAbgrColor(
          section.lineColorKml,
          fallback: kOfficialCourseFallbackColor,
        );
      }
    }

    return kOfficialCourseFallbackColor;
  }

  List<_ActiveTrack> _activeTracksFor(DateTime selectedTime) {
    final result = <_ActiveTrack>[];

    for (final event in _filteredEvents) {
      if (!_isEventVisibleAt(event, selectedTime)) {
        continue;
      }

      final route = event.routePoints
          .where((point) => point.isValid)
          .map(
            (point) => MapPoint(
              latitude: point.latitude!,
              longitude: point.longitude!,
            ),
          )
          .toList(growable: false);
      if (route.length < 2) {
        continue;
      }

      final timedSchedule =
          event.schedulePoints
              .where((point) => point.hasLocation && point.plannedAt != null)
              .toList(growable: false)
            ..sort((a, b) => a.plannedAt!.compareTo(b.plannedAt!));
      if (timedSchedule.isEmpty) {
        continue;
      }

      final timedRoutePoints = <_TimedRoutePoint>[];
      var searchFrom = 0;
      for (final point in timedSchedule) {
        final routeIndex = _nearestRouteIndexFrom(
          route,
          MapPoint(latitude: point.latitude!, longitude: point.longitude!),
          searchFrom,
        );
        searchFrom = routeIndex;
        timedRoutePoints.add(
          _TimedRoutePoint(
            time: point.plannedAt!,
            routeIndex: routeIndex.toDouble(),
          ),
        );
      }

      if (timedRoutePoints.isEmpty) {
        continue;
      }

      final headIndex = _routeIndexAtTime(timedRoutePoints, selectedTime);
      if (headIndex == null) {
        continue;
      }

      final passMinutes = (event.passDurationMinutes ?? 0).clamp(0, 240);
      final routeEnd = timedRoutePoints.last.time;

      if (passMinutes > 0 &&
          selectedTime.isAfter(routeEnd.add(Duration(minutes: passMinutes)))) {
        continue;
      }

      final tailTime = selectedTime.subtract(Duration(minutes: passMinutes));
      final tailIndex = passMinutes <= 0
          ? headIndex
          : (_routeIndexAtTime(timedRoutePoints, tailTime) ??
                timedRoutePoints.first.routeIndex);

      final segment = _sliceRoute(route, tailIndex, headIndex);
      if (segment.length < 2) {
        continue;
      }

      result.add(
        _ActiveTrack(
          brotherhoodSlug: event.brotherhoodSlug,
          brotherhoodName: event.brotherhoodName,
          color: parseHexColor(event.brotherhoodColorHex),
          points: segment,
          head: _pointAtIndex(route, headIndex),
          locationLabel: _closestSchedulePointName(
            timedSchedule,
            timedRoutePoints,
            headIndex,
          ),
        ),
      );
    }

    return result;
  }

  List<MapPoint> _allRoutePoints() {
    return widget.events
        .expand((event) => event.routePoints)
        .where((point) => point.isValid)
        .map(
          (point) =>
              MapPoint(latitude: point.latitude!, longitude: point.longitude!),
        )
        .toList(growable: false);
  }

  Future<void> _fitToBounds(List<_ActiveTrack> activeTracks) async {
    final activePoints = activeTracks.expand((track) => track.points).toList();
    final selectedTime = widget.timeController.selectedTime;
    final visibleRoutes = _visibleRoutes(selectedTime);
    final officialCourse = _officialCourseRoute(selectedTime);
    final visiblePoints = visibleRoutes
        .expand((route) => route.points)
        .toList();
    final fallbackPoints = <MapPoint>[
      ...visiblePoints,
      ...?officialCourse?.points,
    ];
    final pointsForFit = activePoints.isNotEmpty
        ? activePoints
        : fallbackPoints;
    if (pointsForFit.isEmpty) {
      return;
    }

    await easeToPoints(_map, pointsForFit, fallbackZoom: 13.8);
  }

  Future<void> _syncAnnotations(DateTime selectedTime) async {
    final polylineManager = _polylineManager;
    final circleManager = _circleManager;
    if (polylineManager == null || circleManager == null) {
      return;
    }

    await polylineManager.deleteAll();
    await circleManager.deleteAll();

    final visibleRoutes = _visibleRoutes(selectedTime);
    final officialCourse = _officialCourseRoute(selectedTime);
    final activeTracks = _activeTracksFor(selectedTime);
    for (final route in visibleRoutes) {
      await polylineManager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: route.points
                .map((point) => point.toPoint().coordinates)
                .toList(growable: false),
          ),
          lineColor: route.color.withAlpha(28).toARGB32(),
          lineWidth: 3,
        ),
      );
    }
    if (officialCourse != null) {
      await polylineManager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: officialCourse.points
                .map((point) => point.toPoint().coordinates)
                .toList(growable: false),
          ),
          lineColor: officialCourse.color.withAlpha(140).toARGB32(),
          lineWidth: 9,
        ),
      );
    }
    for (final track in activeTracks) {
      await polylineManager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: track.points
                .map((point) => point.toPoint().coordinates)
                .toList(growable: false),
          ),
          lineColor: track.color.toARGB32(),
          lineWidth: 5,
        ),
      );
      await circleManager.create(
        CircleAnnotationOptions(
          geometry: track.head.toPoint(),
          circleColor: track.color.toARGB32(),
          circleRadius: 9,
          circleStrokeColor: Colors.white.toARGB32(),
          circleStrokeWidth: 2,
          customData: <String, Object>{
            'brotherhood': track.brotherhoodName,
            'location': track.locationLabel,
            'lat': track.head.latitude,
            'lng': track.head.longitude,
          },
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
    await _enableUserLocation();
    _circleTapCancelable?.cancel();
    _circleTapCancelable = _circleManager?.tapEvents(
      onTap: (annotation) {
        final data = annotation.customData ?? const <String, Object>{};
        unawaited(_showPointCallout(data));
      },
    );
    await _syncAnnotations(widget.timeController.selectedTime);
  }

  @override
  void didUpdateWidget(covariant _DayMapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedBrotherhoodSlug != 'all' &&
        widget.events.every(
          (event) => event.brotherhoodSlug != _selectedBrotherhoodSlug,
        )) {
      _selectedBrotherhoodSlug = 'all';
    }
    _syncAnnotations(widget.timeController.selectedTime);
  }

  @override
  void dispose() {
    _circleTapCancelable?.cancel();
    _pointCalloutTimer?.cancel();
    _pointCallout.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.timeController,
      builder: (context, child) {
        final selectedTime = widget.timeController.selectedTime;
        const effectiveSelectedBrotherhoodSlug = 'all';
        if (_selectedBrotherhoodSlug != 'all') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedBrotherhoodSlug = 'all';
              });
            }
          });
        }
        final activeTracks = _activeTracksFor(selectedTime);
        final visibleRoutes = _visibleRoutes(selectedTime);
        final legendEvents = _filteredEvents.toList(growable: false);
        final legendItems = <_RouteLegendItem>[
          _RouteLegendItem(
            label: 'Carrera oficial',
            color: _officialCourseLegendColor(),
          ),
          ...legendEvents.map(
            (event) => _RouteLegendItem(
              label: event.brotherhoodName,
              color: parseHexColor(event.brotherhoodColorHex),
            ),
          ),
        ];
        final visiblePoints = visibleRoutes
            .expand((route) => route.points)
            .toList();
        final allRoutePoints = _allRoutePoints();
        final initialPoints = activeTracks
            .expand((track) => track.points)
            .toList();
        final cameraPoints = initialPoints.isNotEmpty
            ? initialPoints
            : (visiblePoints.isNotEmpty ? visiblePoints : allRoutePoints);

        final annotationSignature = [
          selectedTime.toIso8601String(),
          effectiveSelectedBrotherhoodSlug,
          widget.events.length,
        ].join('|');
        if (_lastAnnotationSignature != annotationSignature) {
          _lastAnnotationSignature = annotationSignature;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _syncAnnotations(selectedTime);
          });
        }

        return LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              if (kMapboxAccessToken.isEmpty)
                const MissingMapboxTokenCard()
              else
                MapWidget(
                  key: const ValueKey('day-mapbox-map'),
                  styleUri: mapboxStyleUriForBrightness(
                    Theme.of(context).brightness,
                  ),
                  gestureRecognizers: kMapGestureRecognizers,
                  cameraOptions: cameraForPoints(
                    cameraPoints,
                    fallbackZoom: 13.8,
                  ),
                  viewport: _followUserLocation
                      ? const FollowPuckViewportState(
                          zoom: 15.5,
                          pitch: 0,
                          bearing: FollowPuckViewportStateBearingHeading(),
                        )
                      : null,
                  onCameraChangeListener: (_) {
                    unawaited(_refreshPointCalloutPosition());
                  },
                  onMapCreated: _onMapCreated,
                ),
              Positioned(
                right: 12,
                top: 12,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'day-map-fit-fab',
                      onPressed: () {
                        setState(() => _followUserLocation = false);
                        _fitToBounds(activeTracks);
                      },
                      child: const Icon(Icons.center_focus_strong),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'day-map-location-fab',
                      onPressed: _centerOnUserLocation,
                      child: Icon(
                        _followUserLocation
                            ? Icons.my_location
                            : Icons.location_searching,
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<_MapPointCallout?>(
                valueListenable: _pointCallout,
                builder: (context, callout, child) {
                  if (callout == null) {
                    return const SizedBox.shrink();
                  }

                  const cardWidth = 220.0;
                  final left = math.max(
                    12.0,
                    math.min(
                      callout.x - (cardWidth / 2),
                      constraints.maxWidth - cardWidth - 12,
                    ),
                  );
                  final top = math.max(
                    12.0,
                    math.min(callout.y - 68, constraints.maxHeight - 72),
                  );

                  return Positioned(
                    left: left,
                    top: top,
                    child: GestureDetector(
                      onTap: () {
                        _pointCalloutTimer?.cancel();
                        _pointCallout.value = null;
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: SizedBox(
                                width: cardWidth,
                                child: Text(
                                  callout.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          CustomPaint(
                            size: const ui.Size(18, 10),
                            painter: _CalloutArrowPainter(
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () {
                        setState(() => _showLegend = !_showLegend);
                      },
                      icon: Icon(
                        _showLegend
                            ? Icons.visibility_off_outlined
                            : Icons.palette_outlined,
                      ),
                      label: Text(
                        _showLegend ? 'Ocultar leyenda' : 'Mostrar leyenda',
                      ),
                    ),
                    if (_showLegend) ...[
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (
                                    var i = 0;
                                    i < legendItems.length;
                                    i++
                                  ) ...[
                                    _RouteLegendChip(item: legendItems[i]),
                                    if (i < legendItems.length - 1)
                                      const SizedBox(height: 6),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: SafeArea(
                  top: false,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: _DayTimeSelectorCard(
                        timeController: widget.timeController,
                        compact: true,
                        framed: false,
                      ),
                    ),
                  ),
                ),
              ),
              if (activeTracks.isEmpty)
                const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Text(
                        'No hay tramos activos para la hora seleccionada.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _closestSchedulePointName(
    List<SchedulePoint> timedSchedule,
    List<_TimedRoutePoint> timedRoutePoints,
    double headIndex,
  ) {
    if (timedSchedule.isEmpty || timedRoutePoints.isEmpty) {
      return 'Punto de paso';
    }

    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < timedRoutePoints.length; i++) {
      final distance = (timedRoutePoints[i].routeIndex - headIndex).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    final name = timedSchedule[bestIndex].name.trim();
    return name.isEmpty ? 'Punto de paso' : name;
  }
}

class _MapPointCallout {
  const _MapPointCallout({
    required this.label,
    required this.x,
    required this.y,
    required this.latitude,
    required this.longitude,
  });

  final String label;
  final double x;
  final double y;
  final double? latitude;
  final double? longitude;
}

class _RouteLegendItem {
  const _RouteLegendItem({required this.label, required this.color});

  final String label;
  final Color color;
}

class _RouteLegendChip extends StatelessWidget {
  const _RouteLegendChip({required this.item});

  final _RouteLegendItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 4,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _CalloutArrowPainter extends CustomPainter {
  const _CalloutArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, ui.Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.18), 2, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CalloutArrowPainter oldDelegate) {
    return oldDelegate.color != color;
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
                            styleUri: mapboxStyleUriForBrightness(
                              Theme.of(context).brightness,
                            ),
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

class _ActiveTrack {
  const _ActiveTrack({
    required this.brotherhoodSlug,
    required this.brotherhoodName,
    required this.color,
    required this.points,
    required this.head,
    required this.locationLabel,
  });

  final String brotherhoodSlug;
  final String brotherhoodName;
  final Color color;
  final List<MapPoint> points;
  final MapPoint head;
  final String locationLabel;
}

class _VisibleRoute {
  const _VisibleRoute({required this.color, required this.points});

  final Color color;
  final List<MapPoint> points;
}

class _TimedRoutePoint {
  const _TimedRoutePoint({required this.time, required this.routeIndex});

  final DateTime time;
  final double routeIndex;
}
