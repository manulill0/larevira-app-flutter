import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../config/app_config.dart';
import '../../data/models/day_detail_model.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../live/status_style.dart';
import '../time/simulated_clock_controller.dart';
import '../utils/color_utils.dart';
import '../widgets/app_scaffold_background.dart';
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
    required this.simulatedClockController,
  });

  final String daySlug;
  final String dayName;
  final String mode;
  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final SimulatedClockController simulatedClockController;

  @override
  State<DayBrotherhoodsPage> createState() => _DayBrotherhoodsPageState();
}

class _DayBrotherhoodsPageState extends State<DayBrotherhoodsPage> {
  int _selectedIndex = 0;
  late Future<DayDetail> _future;

  @override
  void initState() {
    super.initState();
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
      body: AppScaffoldBackground(
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
                _DayScheduleTab(events: detail.processionEvents),
                _DayMapTab(events: detail.processionEvents),
                _DayBrotherhoodsTab(
                  events: detail.processionEvents,
                  repository: widget.repository,
                  config: widget.config,
                  favoritesController: widget.favoritesController,
                  simulatedClockController: widget.simulatedClockController,
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
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
        ],
      ),
    );
  }
}

class _DayScheduleRow {
  const _DayScheduleRow({
    required this.brotherhoodName,
    required this.status,
    required this.pointName,
    required this.plannedAt,
  });

  final String brotherhoodName;
  final String status;
  final String pointName;
  final DateTime? plannedAt;
}

class _DayScheduleTab extends StatelessWidget {
  const _DayScheduleTab({required this.events});

  final List<DayProcessionEvent> events;

  List<_DayScheduleRow> get _rows {
    final rows = <_DayScheduleRow>[];
    for (final event in events) {
      for (final point in event.schedulePoints) {
        rows.add(
          _DayScheduleRow(
            brotherhoodName: event.brotherhoodName,
            status: event.status,
            pointName: point.name,
            plannedAt: point.plannedAt,
          ),
        );
      }
    }

    rows.sort((a, b) {
      final at = a.plannedAt;
      final bt = b.plannedAt;
      if (at == null && bt == null) {
        return a.brotherhoodName.compareTo(b.brotherhoodName);
      }
      if (at == null) {
        return 1;
      }
      if (bt == null) {
        return -1;
      }
      final byTime = at.compareTo(bt);
      if (byTime != 0) {
        return byTime;
      }
      return a.brotherhoodName.compareTo(b.brotherhoodName);
    });

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    if (rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No hay puntos horarios cargados para esta jornada.'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          'Horario de la jornada',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Hora')),
                DataColumn(label: Text('Punto')),
                DataColumn(label: Text('Hermandad')),
                DataColumn(label: Text('Estado')),
              ],
              rows: rows
                  .map(
                    (row) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            row.plannedAt == null
                                ? '--:--'
                                : DateFormat('HH:mm').format(row.plannedAt!),
                          ),
                        ),
                        DataCell(Text(row.pointName)),
                        DataCell(Text(row.brotherhoodName)),
                        DataCell(Text(statusStyleFor(row.status).label)),
                      ],
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ],
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
  final MapController _mapController = MapController();

  List<_RouteLine> get _routeLines => widget.events
      .map(
        (event) => _RouteLine(
          points: event.routePoints
              .where((point) => point.isValid)
              .map((point) => LatLng(point.latitude!, point.longitude!))
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
            location: LatLng(point.latitude!, point.longitude!),
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

  List<LatLng> get _allPoints {
    final route = _routeLines.expand((line) => line.points);
    final markers = _markers.map((marker) => marker.location);
    return [...route, ...markers];
  }

  LatLng get _initialCenter =>
      _allPoints.isNotEmpty ? _allPoints.first : const LatLng(37.3891, -5.9845);

  void _fitToBounds() {
    if (_allPoints.isEmpty) {
      return;
    }
    final bounds = LatLngBounds.fromPoints(_allPoints);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(32)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = _markers;
    final routeLines = _routeLines;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: 13.8,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.doubleTapZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.larevira.app',
            ),
            for (final line in routeLines)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: line.points,
                    strokeWidth: 4,
                    color: line.color,
                  ),
                ],
              ),
            MarkerLayer(
              markers: markers
                  .map(
                    (marker) => Marker(
                      point: marker.location,
                      width: 24,
                      height: 24,
                      child: Tooltip(
                        message:
                            '${marker.brotherhoodName} · ${marker.pointName} (${marker.hourLabel})',
                        child: Icon(
                          Icons.circle,
                          size: 12,
                          color: marker.color,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
        Positioned(
          right: 12,
          top: 12,
          child: FloatingActionButton.small(
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
    required this.events,
    required this.repository,
    required this.config,
    required this.favoritesController,
    required this.simulatedClockController,
  });

  final List<DayProcessionEvent> events;
  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final SimulatedClockController simulatedClockController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: favoritesController,
      builder: (context, child) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemBuilder: (context, index) {
            final event = events[index];
            final isFavorite = favoritesController.isFavorite(event.brotherhoodSlug);
            final statusStyle = statusStyleFor(event.status);

            return Card(
              child: ListTile(
                leading: Icon(
                  isFavorite ? Icons.star : Icons.church_outlined,
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
                trailing: const Icon(Icons.chevron_right),
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
                              simulatedClockController: simulatedClockController,
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
  }
}

class _RouteLine {
  const _RouteLine({required this.points, required this.color});

  final List<LatLng> points;
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

  final LatLng location;
  final String brotherhoodName;
  final String pointName;
  final DateTime? plannedAt;
  final Color color;

  String get hourLabel =>
      plannedAt == null ? '--:--' : DateFormat('HH:mm').format(plannedAt!);
}
