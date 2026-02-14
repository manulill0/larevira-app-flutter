class DayDetail {
  const DayDetail({
    required this.slug,
    required this.name,
    required this.mode,
    required this.processionEvents,
  });

  final String slug;
  final String name;
  final String mode;
  final List<DayProcessionEvent> processionEvents;

  factory DayDetail.fromJson(Map<String, dynamic> json) {
    final rawEvents = (json['procession_events'] as List<dynamic>? ?? const []);
    return DayDetail(
      slug: (json['slug'] ?? '') as String,
      name: (json['name'] ?? 'Jornada') as String,
      mode: (json['mode'] ?? 'all') as String,
      processionEvents: rawEvents
          .whereType<Map<String, dynamic>>()
          .map(DayProcessionEvent.fromJson)
          .toList(growable: false),
    );
  }
}

class DayProcessionEvent {
  const DayProcessionEvent({
    required this.status,
    required this.officialNote,
    required this.brotherhoodName,
    required this.brotherhoodSlug,
    required this.brotherhoodColorHex,
    required this.routePoints,
    required this.schedulePoints,
  });

  final String status;
  final String officialNote;
  final String brotherhoodName;
  final String brotherhoodSlug;
  final String brotherhoodColorHex;
  final List<GeoPoint> routePoints;
  final List<SchedulePoint> schedulePoints;

  factory DayProcessionEvent.fromJson(Map<String, dynamic> json) {
    final brotherhood = (json['brotherhood'] as Map<String, dynamic>? ?? const {});
    final rawPoints = (json['schedule_points'] as List<dynamic>? ?? const []);
    final route = (json['route'] as Map<String, dynamic>? ?? const {});
    final rawRouteWaypoints = (route['waypoints'] as List<dynamic>? ?? const []);

    return DayProcessionEvent(
      status: (json['status'] ?? 'scheduled') as String,
      officialNote: (json['official_note'] ?? '') as String,
      brotherhoodName: (brotherhood['name'] ?? 'Hermandad') as String,
      brotherhoodSlug: (brotherhood['slug'] ?? '') as String,
      brotherhoodColorHex: (brotherhood['color_hex'] ?? '#8B1E3F') as String,
      routePoints: rawRouteWaypoints
          .whereType<Map<String, dynamic>>()
          .map(GeoPoint.fromJson)
          .where((point) => point.isValid)
          .toList(growable: false),
      schedulePoints: rawPoints
          .whereType<Map<String, dynamic>>()
          .map(SchedulePoint.fromJson)
          .toList(growable: false),
    );
  }
}

class SchedulePoint {
  const SchedulePoint({
    required this.name,
    required this.plannedAt,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final DateTime? plannedAt;
  final double? latitude;
  final double? longitude;
  bool get hasLocation => latitude != null && longitude != null;

  factory SchedulePoint.fromJson(Map<String, dynamic> json) {
    return SchedulePoint(
      name: (json['name'] ?? 'Punto') as String,
      plannedAt: DateTime.tryParse((json['planned_at'] ?? '') as String),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }
}

class GeoPoint {
  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  final double? latitude;
  final double? longitude;
  bool get isValid => latitude != null && longitude != null;

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
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
