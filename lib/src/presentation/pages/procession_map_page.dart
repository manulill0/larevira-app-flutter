import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../data/models/day_detail_model.dart';
import '../live/status_style.dart';
import '../maps/mapbox_map_helpers.dart';
import '../utils/color_utils.dart';
import '../widgets/missing_mapbox_token_card.dart';

class ProcessionMapPage extends StatefulWidget {
  const ProcessionMapPage({
    super.key,
    required this.title,
    required this.colorHex,
    required this.routePoints,
    required this.schedulePoints,
    required this.status,
  });

  final String title;
  final String colorHex;
  final List<GeoPoint> routePoints;
  final List<SchedulePoint> schedulePoints;
  final String status;

  @override
  State<ProcessionMapPage> createState() => _ProcessionMapPageState();
}

class _ProcessionMapPageState extends State<ProcessionMapPage> {
  MapboxMap? _map;
  PolylineAnnotationManager? _polylineManager;
  CircleAnnotationManager? _circleManager;

  List<MapPoint> get _polylinePoints => widget.routePoints
      .where((point) => point.isValid)
      .map(
        (point) =>
            MapPoint(latitude: point.latitude!, longitude: point.longitude!),
      )
      .toList(growable: false);

  List<MapPoint> get _scheduleLatLngs => widget.schedulePoints
      .where((point) => point.hasLocation)
      .map(
        (point) =>
            MapPoint(latitude: point.latitude!, longitude: point.longitude!),
      )
      .toList(growable: false);

  List<MapPoint> get _allPoints => [..._polylinePoints, ..._scheduleLatLngs];

  CameraOptions get _initialCamera =>
      cameraForPoints(_allPoints, fallbackZoom: 14);

  Future<void> _fitToRoute() async {
    await easeToPoints(_map, _allPoints, fallbackZoom: 14);
  }

  Future<void> _syncAnnotations() async {
    final polylineManager = _polylineManager;
    final circleManager = _circleManager;
    if (polylineManager == null || circleManager == null) {
      return;
    }

    await polylineManager.deleteAll();
    await circleManager.deleteAll();

    final color = parseHexColor(widget.colorHex);

    if (_polylinePoints.length >= 2) {
      await polylineManager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: _polylinePoints
                .map((point) => point.toPoint().coordinates)
                .toList(growable: false),
          ),
          lineColor: color.toARGB32(),
          lineWidth: 5,
        ),
      );
    }

    for (final point in _scheduleLatLngs) {
      await circleManager.create(
        CircleAnnotationOptions(
          geometry: point.toPoint(),
          circleColor: const Color(0xFF8B1E3F).toARGB32(),
          circleRadius: 6,
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
    await _syncAnnotations();
  }

  @override
  void didUpdateWidget(covariant ProcessionMapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnnotations();
  }

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(widget.colorHex);
    final style = statusStyleFor(widget.status);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'procession-map-fit-fab',
        onPressed: _fitToRoute,
        child: const Icon(Icons.center_focus_strong),
      ),
      body: Stack(
        children: [
          if (kMapboxAccessToken.isEmpty)
            const MissingMapboxTokenCard()
          else
            MapWidget(
              key: const ValueKey('procession-mapbox-map'),
              styleUri: kMapboxStyleUri,
              gestureRecognizers: kMapGestureRecognizers,
              cameraOptions: _initialCamera,
              onMapCreated: _onMapCreated,
            ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                style.label,
                style: TextStyle(
                  color: style.foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 18, height: 4, color: color),
                    const SizedBox(width: 6),
                    const Text('Ruta'),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color: Color(0xFF8B1E3F),
                    ),
                    const SizedBox(width: 4),
                    const Text('Puntos'),
                  ],
                ),
              ),
            ),
          ),
          if (_polylinePoints.length < 2 && _scheduleLatLngs.isEmpty)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Esta cofradía aún no tiene coordenadas de itinerario.',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
