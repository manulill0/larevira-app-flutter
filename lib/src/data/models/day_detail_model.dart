import 'route_section_model.dart';

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
    required this.passDurationMinutes,
    required this.brotherhoodName,
    required this.brotherhoodSlug,
    required this.brotherhoodColorHex,
    required this.routePoints,
    required this.routeSections,
    required this.schedulePoints,
  });

  final String status;
  final String officialNote;
  final int? passDurationMinutes;
  final String brotherhoodName;
  final String brotherhoodSlug;
  final String brotherhoodColorHex;
  final List<GeoPoint> routePoints;
  final List<RouteSection> routeSections;
  final List<SchedulePoint> schedulePoints;

  factory DayProcessionEvent.fromJson(Map<String, dynamic> json) {
    final brotherhood =
        (json['brotherhood'] as Map<String, dynamic>? ?? const {});
    final itinerary = (json['itinerary'] as Map<String, dynamic>? ?? const {});
    final rawPoints =
        (itinerary['schedule_points'] as List<dynamic>? ?? const []);
    final rawRoutePathPoints =
        (itinerary['path_points'] as List<dynamic>? ?? const []);
    final rawRoutePolyline =
        (itinerary['polyline'] as List<dynamic>? ?? const []);
    final rawRouteSections =
        (itinerary['route_sections'] as List<dynamic>? ?? const []);

    return DayProcessionEvent(
      status: (json['status'] ?? 'scheduled') as String,
      officialNote: (json['official_note'] ?? '') as String,
      passDurationMinutes: (json['pass_duration_minutes'] as num?)?.toInt(),
      brotherhoodName: (brotherhood['name'] ?? 'Hermandad') as String,
      brotherhoodSlug: (brotherhood['slug'] ?? '') as String,
      brotherhoodColorHex: (brotherhood['color_hex'] ?? '#8B1E3F') as String,
      routePoints:
          (rawRoutePathPoints.isNotEmpty
                  ? rawRoutePathPoints
                  : rawRoutePolyline)
              .whereType<Map<String, dynamic>>()
              .map(GeoPoint.fromJson)
              .where((point) => point.isValid)
              .toList(growable: false),
      routeSections: rawRouteSections
          .whereType<Map<String, dynamic>>()
          .map(RouteSection.fromJson)
          .where((section) => section.points.length >= 2)
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
      plannedAt: _parseDateTimeWallClock((json['planned_at'] ?? '') as String),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }
}

class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude});

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

DateTime? _parseDateTimeWallClock(String raw) {
  final value = raw.trim();
  if (value.isEmpty) {
    return null;
  }

  final match = RegExp(
    r'^(\\d{4})-(\\d{2})-(\\d{2})[T ](\\d{2}):(\\d{2})(?::(\\d{2}))?',
  ).firstMatch(value);
  if (match != null) {
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6) ?? '0'),
    );
  }

  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return null;
  }

  return DateTime(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  );
}
