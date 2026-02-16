import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../config/app_config.dart';
import '../../data/models/brotherhood_detail_model.dart';
import '../../data/repositories/larevira_repository.dart';
import '../favorites/favorites_controller.dart';
import '../maps/mapbox_map_helpers.dart';
import '../time/simulated_clock_controller.dart';
import '../utils/color_utils.dart';
import '../widgets/app_scaffold_background.dart';
import '../widgets/missing_mapbox_token_card.dart';

class BrotherhoodDetailPage extends StatelessWidget {
  const BrotherhoodDetailPage({
    super.key,
    required this.brotherhoodSlug,
    required this.title,
    required this.repository,
    required this.config,
    required this.favoritesController,
    required this.simulatedClockController,
    this.embedded = false,
  });

  final String brotherhoodSlug;
  final String title;
  final LareviraRepository repository;
  final AppConfig config;
  final FavoritesController favoritesController;
  final SimulatedClockController simulatedClockController;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = AppScaffoldBackground(
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
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
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
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ListenableBuilder(
            listenable: favoritesController,
            builder: (context, child) {
              final isFavorite = favoritesController.isFavorite(
                brotherhoodSlug,
              );
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
      body: content,
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
                            detail.fullName.isEmpty
                                ? 'Hermandad'
                                : detail.fullName,
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
      child: SizedBox(height: extent, child: tabBar),
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
        const Text('Salida', style: TextStyle(fontWeight: FontWeight.w800)),
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
        const Text('Recorrido', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          detail.routeDescription.isEmpty
              ? 'Recorrido no disponible.'
              : detail.routeDescription,
        ),
        const SizedBox(height: 16),
        const Text('Pasos', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (detail.pasoNames.isEmpty)
          const Text('No hay pasos cargados.')
        else
          ...detail.pasoNames.asMap().entries.map(
            (entry) => Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${entry.key + 1}')),
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
          ...detail.itineraryPoints.asMap().entries.map((entry) {
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
          }),
      ],
    );
  }
}

class _MapTab extends StatefulWidget {
  const _MapTab({required this.detail, required this.simulatedClockController});

  final BrotherhoodDetail detail;
  final SimulatedClockController simulatedClockController;

  @override
  State<_MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<_MapTab> {
  MapboxMap? _map;
  PolylineAnnotationManager? _polylineManager;
  CircleAnnotationManager? _circleManager;

  List<BrotherhoodItineraryPoint> get _pointsWithLocation => widget
      .detail
      .itineraryPoints
      .where((point) => point.hasLocation)
      .toList(growable: false);

  List<MapPoint> get _routePoints => _pointsWithLocation
      .map(
        (point) =>
            MapPoint(latitude: point.latitude!, longitude: point.longitude!),
      )
      .toList(growable: false);

  CameraOptions get _initialCamera =>
      cameraForPoints(_routePoints, fallbackZoom: 14);

  _WaypointTiming _timingFor(BrotherhoodItineraryPoint point, DateTime now) {
    final plannedAt = point.plannedAt;
    if (plannedAt == null) {
      return _WaypointTiming.unknown;
    }
    return plannedAt.isBefore(now)
        ? _WaypointTiming.past
        : _WaypointTiming.upcoming;
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

  Future<void> _fitRoute() async {
    await easeToPoints(_map, _routePoints, fallbackZoom: 14);
  }

  Future<void> _syncAnnotations(DateTime now) async {
    final polylineManager = _polylineManager;
    final circleManager = _circleManager;
    if (polylineManager == null || circleManager == null) {
      return;
    }

    await polylineManager.deleteAll();
    await circleManager.deleteAll();

    final color = parseHexColor(widget.detail.colorHex);
    if (_routePoints.length >= 2) {
      await polylineManager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: _routePoints
                .map((point) => point.toPoint().coordinates)
                .toList(growable: false),
          ),
          lineColor: color.toARGB32(),
          lineWidth: 5,
        ),
      );
    }

    for (final pointData in _pointsWithLocation) {
      final timing = _timingFor(pointData, now);
      final markerColor = _markerColorFor(timing, color);
      await circleManager.create(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(pointData.longitude!, pointData.latitude!),
          ),
          circleColor: markerColor.toARGB32(),
          circleRadius: 7,
          circleStrokeColor: Colors.white.toARGB32(),
          circleStrokeWidth: 1.5,
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
    await _syncAnnotations(widget.simulatedClockController.now);
  }

  @override
  void didUpdateWidget(covariant _MapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnnotations(widget.simulatedClockController.now);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.simulatedClockController,
      builder: (context, child) {
        final now = widget.simulatedClockController.now;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _syncAnnotations(now);
        });
        return Stack(
          children: [
            if (kMapboxAccessToken.isEmpty)
              const MissingMapboxTokenCard()
            else
              MapWidget(
                key: const ValueKey('brotherhood-mapbox-map'),
                styleUri: kMapboxStyleUri,
                gestureRecognizers: kMapGestureRecognizers,
                cameraOptions: _initialCamera,
                onMapCreated: _onMapCreated,
              ),
            // Positioned(
            //   left: 12,
            //   bottom: 48,
            //   child: Card(
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 10,
            //         vertical: 8,
            //       ),
            //       child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           _LegendDot(
            //             color: _markerColorFor(_WaypointTiming.past, color),
            //             icon: Icons.location_on_outlined,
            //             label: 'Pasado',
            //           ),
            //           const SizedBox(width: 10),
            //           _LegendDot(
            //             color: _markerColorFor(_WaypointTiming.upcoming, color),
            //             icon: Icons.location_on,
            //             label: 'Próximo',
            //           ),
            //           const SizedBox(width: 10),
            //           _LegendDot(
            //             color: _markerColorFor(_WaypointTiming.unknown, color),
            //             icon: Icons.location_on,
            //             label: 'Sin hora',
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
              right: 12,
              bottom: 48,
              child: FloatingActionButton.small(
                heroTag: 'brotherhood-map-fit-fab',
                onPressed: _fitRoute,
                child: const Icon(Icons.center_focus_strong),
              ),
            ),
            if (_pointsWithLocation.isEmpty)
              const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'No hay waypoints con coordenadas para esta hermandad.',
                    ),
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

class _ItineraryPointMapPage extends StatefulWidget {
  const _ItineraryPointMapPage({
    required this.title,
    required this.detail,
    required this.point,
  });

  final String title;
  final BrotherhoodDetail detail;
  final BrotherhoodItineraryPoint point;

  @override
  State<_ItineraryPointMapPage> createState() => _ItineraryPointMapPageState();
}

class _ItineraryPointMapPageState extends State<_ItineraryPointMapPage> {
  CircleAnnotationManager? _circleManager;

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _circleManager = await mapboxMap.annotations
        .createCircleAnnotationManager();
    await _syncAnnotation();
  }

  Future<void> _syncAnnotation() async {
    final circleManager = _circleManager;
    if (circleManager == null || !widget.point.hasLocation) {
      return;
    }

    await circleManager.deleteAll();
    final color = parseHexColor(widget.detail.colorHex);
    await circleManager.create(
      CircleAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            widget.point.longitude!,
            widget.point.latitude!,
          ),
        ),
        circleColor: color.toARGB32(),
        circleRadius: 8,
        circleStrokeColor: Colors.white.toARGB32(),
        circleStrokeWidth: 1.5,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _ItineraryPointMapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnnotation();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.point.hasLocation) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
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

    final color = parseHexColor(widget.detail.colorHex);
    final center = MapPoint(
      latitude: widget.point.latitude!,
      longitude: widget.point.longitude!,
    );
    final hour = widget.point.plannedAt == null
        ? '--:--'
        : DateFormat('HH:mm').format(widget.point.plannedAt!);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          if (kMapboxAccessToken.isEmpty)
            const MissingMapboxTokenCard()
          else
            MapWidget(
              key: ValueKey('itinerary-point-mapbox-${widget.point.name}'),
              styleUri: kMapboxStyleUri,
              gestureRecognizers: kMapGestureRecognizers,
              cameraOptions: CameraOptions(center: center.toPoint(), zoom: 16),
              onMapCreated: _onMapCreated,
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                ),
              ),
            ),
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
                      widget.point.name,
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
