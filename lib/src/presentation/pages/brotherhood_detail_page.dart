import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../config/app_config.dart';
import '../../data/models/brotherhood_detail_model.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../time/simulated_clock_controller.dart';
import '../utils/color_utils.dart';
import '../widgets/app_scaffold_background.dart';

class BrotherhoodDetailPage extends StatelessWidget {
  const BrotherhoodDetailPage({
    super.key,
    required this.brotherhoodSlug,
    required this.title,
    required this.repository,
    required this.config,
    required this.favoritesController,
    required this.simulatedClockController,
  });

  final String brotherhoodSlug;
  final String title;
  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final SimulatedClockController simulatedClockController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ListenableBuilder(
            listenable: favoritesController,
            builder: (context, child) {
              final isFavorite = favoritesController.isFavorite(brotherhoodSlug);
              return IconButton(
                onPressed: () => favoritesController.toggle(brotherhoodSlug),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? const Color(0xFFC9983E) : null,
                ),
              );
            },
          ),
        ],
      ),
      body: AppScaffoldBackground(
        child: FutureBuilder<BrotherhoodDetail>(
          future: repository.getBrotherhoodDetail(
            citySlug: config.citySlug,
            year: config.editionYear,
            brotherhoodSlug: brotherhoodSlug,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(snapshot.error.toString(), textAlign: TextAlign.center),
                ),
              );
            }

            final detail = snapshot.data;
            if (detail == null) {
              return const Center(child: Text('Sin datos de hermandad.'));
            }

            return _BrotherhoodDetailContent(
              detail: detail,
              simulatedClockController: simulatedClockController,
            );
          },
        ),
      ),
    );
  }
}

class _BrotherhoodDetailContent extends StatelessWidget {
  const _BrotherhoodDetailContent({
    required this.detail,
    required this.simulatedClockController,
  });

  final BrotherhoodDetail detail;
  final SimulatedClockController simulatedClockController;

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(detail.colorHex);
    final tabBar = const TabBar(
      tabs: [
        Tab(text: 'Información'),
        Tab(text: 'Itinerario'),
        Tab(text: 'Mapa'),
      ],
    );

    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 280,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [color, const Color(0xFF2E1717)],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 8),
                        child: Icon(
                          Icons.church_outlined,
                          size: 180,
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (detail.dayLabel.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                detail.dayLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Text(
                            detail.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 34,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            detail.fullName.isEmpty ? 'Hermandad' : detail.fullName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.schedule,
                        label: 'Horario',
                        value: detail.departureAt == null
                            ? '--:--'
                            : DateFormat('HH:mm').format(detail.departureAt!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.alt_route,
                        label: 'Pasos',
                        value: '${detail.pasoNames.length}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarHeaderDelegate(tabBar: tabBar),
            ),
          ];
        },
        body: TabBarView(
          children: [
            _InfoTab(detail: detail),
            _ItineraryTab(detail: detail),
            _MapTab(
              detail: detail,
              simulatedClockController: simulatedClockController,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarHeaderDelegate({required this.tabBar});

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final extent = maxExtent;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: overlapsContent ? 1 : 0,
      child: SizedBox(
        height: extent,
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 8),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({required this.detail});

  final BrotherhoodDetail detail;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Text(
          'Descripción',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          detail.history.isEmpty
              ? 'Sin descripción disponible.'
              : detail.history,
        ),
        const SizedBox(height: 18),
        const Text(
          'Salida',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          detail.headquartersName.isEmpty
              ? 'No disponible'
              : detail.headquartersName,
        ),
        if (detail.headquartersAddress.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(detail.headquartersAddress),
        ],
        const SizedBox(height: 18),
        const Text(
          'Recorrido',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          detail.routeDescription.isEmpty
              ? 'Recorrido no disponible.'
              : detail.routeDescription,
        ),
        const SizedBox(height: 16),
        const Text(
          'Pasos',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (detail.pasoNames.isEmpty)
          const Text('No hay pasos cargados.')
        else
          ...detail.pasoNames.asMap().entries.map(
                (entry) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${entry.key + 1}'),
                    ),
                    title: Text(entry.value),
                  ),
                ),
              ),
      ],
    );
  }
}

class _ItineraryTab extends StatelessWidget {
  const _ItineraryTab({required this.detail});

  final BrotherhoodDetail detail;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Text(
          'Itinerario por horas',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (detail.itineraryPoints.isEmpty)
          const Text('No hay puntos horarios cargados para esta hermandad.')
        else
          ...detail.itineraryPoints.asMap().entries.map(
                (entry) {
                  final point = entry.value;
                  final hour = point.plannedAt == null
                      ? '--:--'
                      : DateFormat('HH:mm').format(point.plannedAt!);
                  return Card(
                    child: ListTile(
                      onTap: point.hasLocation
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => _ItineraryPointMapPage(
                                    title: point.name,
                                    detail: detail,
                                    point: point,
                                  ),
                                ),
                              );
                            }
                          : null,
                      leading: CircleAvatar(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      title: Text(point.name),
                      subtitle: point.hasLocation
                          ? null
                          : const Text('Sin coordenadas para este punto'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hour,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.map_outlined,
                            color: point.hasLocation
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).disabledColor,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}

class _MapTab extends StatefulWidget {
  const _MapTab({
    required this.detail,
    required this.simulatedClockController,
  });

  final BrotherhoodDetail detail;
  final SimulatedClockController simulatedClockController;

  @override
  State<_MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<_MapTab> {
  final MapController _mapController = MapController();

  List<BrotherhoodItineraryPoint> get _pointsWithLocation => widget.detail.itineraryPoints
      .where((point) => point.hasLocation)
      .toList(growable: false);

  List<LatLng> get _routePoints => _pointsWithLocation
      .map((point) => LatLng(point.latitude!, point.longitude!))
      .toList(growable: false);

  LatLng get _center => _routePoints.isNotEmpty
      ? _routePoints.first
      : const LatLng(37.3891, -5.9845);

  _WaypointTiming _timingFor(BrotherhoodItineraryPoint point, DateTime now) {
    final plannedAt = point.plannedAt;
    if (plannedAt == null) {
      return _WaypointTiming.unknown;
    }
    return plannedAt.isBefore(now) ? _WaypointTiming.past : _WaypointTiming.upcoming;
  }

  Color _markerColorFor(_WaypointTiming timing, Color accent) {
    switch (timing) {
      case _WaypointTiming.past:
        return const Color(0xFF6E7D8C);
      case _WaypointTiming.upcoming:
        return accent;
      case _WaypointTiming.unknown:
        return const Color(0xFFB58A3A);
    }
  }

  void _fitRoute() {
    if (_routePoints.isEmpty) {
      return;
    }
    final bounds = LatLngBounds.fromPoints(_routePoints);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.simulatedClockController,
      builder: (context, child) {
        final color = parseHexColor(widget.detail.colorHex);
        final now = widget.simulatedClockController.now;
        return Stack(
          children: [
            FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom |
                  InteractiveFlag.drag |
                  InteractiveFlag.doubleTapZoom,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.larevira.app',
            ),
            if (_routePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: color,
                    strokeWidth: 5,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (var i = 0; i < _pointsWithLocation.length; i++)
                  () {
                    final pointData = _pointsWithLocation[i];
                    final timing = _timingFor(pointData, now);
                    final markerColor = _markerColorFor(timing, color);
                    final hour = pointData.plannedAt == null
                        ? '--:--'
                        : DateFormat('HH:mm').format(pointData.plannedAt!);
                    return Marker(
                      point: LatLng(
                        pointData.latitude!,
                        pointData.longitude!,
                      ),
                      width: 34,
                      height: 34,
                      child: Tooltip(
                        message: '${pointData.name} ($hour)',
                        child: Icon(
                          timing == _WaypointTiming.past
                              ? Icons.location_on_outlined
                              : Icons.location_on,
                          color: markerColor,
                          size: 32,
                        ),
                      ),
                    );
                  }(),
              ],
            ),
          ],
        ),
            Positioned(
              left: 12,
              top: 12,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LegendDot(
                        color: _markerColorFor(_WaypointTiming.past, color),
                        icon: Icons.location_on_outlined,
                        label: 'Pasado',
                      ),
                      const SizedBox(width: 10),
                      _LegendDot(
                        color: _markerColorFor(_WaypointTiming.upcoming, color),
                        icon: Icons.location_on,
                        label: 'Próximo',
                      ),
                      const SizedBox(width: 10),
                      _LegendDot(
                        color: _markerColorFor(_WaypointTiming.unknown, color),
                        icon: Icons.location_on,
                        label: 'Sin hora',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: FloatingActionButton.small(
                onPressed: _fitRoute,
                child: const Icon(Icons.center_focus_strong),
              ),
            ),
            if (_pointsWithLocation.isEmpty)
              const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text('No hay waypoints con coordenadas para esta hermandad.'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

enum _WaypointTiming { past, upcoming, unknown }

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _ItineraryPointMapPage extends StatelessWidget {
  const _ItineraryPointMapPage({
    required this.title,
    required this.detail,
    required this.point,
  });

  final String title;
  final BrotherhoodDetail detail;
  final BrotherhoodItineraryPoint point;

  @override
  Widget build(BuildContext context) {
    if (!point.hasLocation) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Este punto no tiene coordenadas disponibles.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final color = parseHexColor(detail.colorHex);
    final center = LatLng(point.latitude!, point.longitude!);
    final hour = point.plannedAt == null
        ? '--:--'
        : DateFormat('HH:mm').format(point.plannedAt!);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 16,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.larevira.app',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: center,
                    radius: 46,
                    color: color.withValues(alpha: 0.15),
                    borderStrokeWidth: 2,
                    borderColor: color,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 34,
                    height: 34,
                    child: Icon(Icons.location_on, size: 34, color: color),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text('Hora prevista: $hour'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
