class RouteSection {
  const RouteSection({
    required this.name,
    required this.lineColorKml,
    required this.points,
  });

  final String name;
  final String? lineColorKml;
  final List<RouteSectionPoint> points;

  factory RouteSection.fromJson(Map<String, dynamic> json) {
    final rawPoints = (json['points'] as List<dynamic>? ?? const []);

    return RouteSection(
      name: (json['name'] ?? '') as String,
      lineColorKml: (json['color'] as String?)?.trim(),
      points: rawPoints
          .whereType<Map<String, dynamic>>()
          .map(RouteSectionPoint.fromJson)
          .where((point) => point.hasLocation)
          .toList(growable: false),
    );
  }
}

class RouteSectionPoint {
  const RouteSectionPoint({required this.latitude, required this.longitude});

  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;

  factory RouteSectionPoint.fromJson(Map<String, dynamic> json) {
    return RouteSectionPoint(
      latitude: _toDouble(json['lat'] ?? json['latitude']),
      longitude: _toDouble(json['lng'] ?? json['lon'] ?? json['longitude']),
    );
  }
}

double? _toDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}
