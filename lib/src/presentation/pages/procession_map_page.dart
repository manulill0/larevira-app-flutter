import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/day_detail_model.dart';
import '../live/status_style.dart';
import '../utils/color_utils.dart';

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
  final _mapController = MapController();

  List<LatLng> get _polylinePoints => widget.routePoints
      .where((point) => point.isValid)
      .map((point) => LatLng(point.latitude!, point.longitude!))
      .toList(growable: false);

  List<LatLng> get _scheduleLatLngs => widget.schedulePoints
      .where((point) => point.hasLocation)
      .map((point) => LatLng(point.latitude!, point.longitude!))
      .toList(growable: false);

  List<LatLng> get _allPoints => [..._polylinePoints, ..._scheduleLatLngs];

  LatLng get _fallbackCenter => _allPoints.isNotEmpty
      ? _allPoints.first
      : const LatLng(37.3891, -5.9845);

  void _fitToRoute() {
    if (_allPoints.isEmpty) {
      return;
    }

    final bounds = LatLngBounds.fromPoints(_allPoints);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(widget.colorHex);
    final style = statusStyleFor(widget.status);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _fitToRoute,
        child: const Icon(Icons.center_focus_strong),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _fallbackCenter,
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
              if (_polylinePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polylinePoints,
                      color: color,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (var i = 0; i < widget.schedulePoints.length; i++)
                    if (widget.schedulePoints[i].hasLocation)
                      Marker(
                        point: LatLng(
                          widget.schedulePoints[i].latitude!,
                          widget.schedulePoints[i].longitude!,
                        ),
                        width: 28,
                        height: 28,
                        child: Tooltip(
                          message: widget.schedulePoints[i].name,
                          child: const Icon(
                            Icons.location_on,
                            size: 28,
                            color: Color(0xFF8B1E3F),
                          ),
                        ),
                      ),
                ],
              ),
            ],
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
                    Container(
                      width: 18,
                      height: 4,
                      color: color,
                    ),
                    const SizedBox(width: 6),
                    const Text('Ruta'),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on, size: 18, color: Color(0xFF8B1E3F)),
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
                  child: Text('Esta cofradía aún no tiene coordenadas de itinerario.'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
