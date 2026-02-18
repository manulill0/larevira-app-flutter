class BrotherhoodDetail {
  const BrotherhoodDetail({
    required this.name,
    required this.fullName,
    required this.history,
    required this.foundationYear,
    required this.colorHex,
    required this.headquartersName,
    required this.headquartersAddress,
    required this.figuresCount,
    required this.pasosCount,
    required this.bandsCount,
    required this.debutsCount,
    required this.newsTitles,
    required this.pasoNames,
    required this.dayLabel,
    required this.departureAt,
    required this.routeDescription,
    required this.routePoints,
    required this.itineraryPoints,
  });

  final String name;
  final String fullName;
  final String history;
  final int? foundationYear;
  final String colorHex;
  final String headquartersName;
  final String headquartersAddress;
  final int figuresCount;
  final int pasosCount;
  final int bandsCount;
  final int debutsCount;
  final List<String> newsTitles;
  final List<String> pasoNames;
  final String dayLabel;
  final DateTime? departureAt;
  final String routeDescription;
  final List<BrotherhoodRoutePoint> routePoints;
  final List<BrotherhoodItineraryPoint> itineraryPoints;

  factory BrotherhoodDetail.fromJson(Map<String, dynamic> json) {
    final headquarters =
        (json['headquarters'] as Map<String, dynamic>? ?? const {});
    final news = (json['news'] as List<dynamic>? ?? const []);
    final pasos = (json['pasos'] as List<dynamic>? ?? const []);
    final events = (json['procession_events'] as List<dynamic>? ?? const []);
    final firstEvent = events.isNotEmpty && events.first is Map<String, dynamic>
        ? events.first as Map<String, dynamic>
        : const <String, dynamic>{};
    final editionDay =
        (firstEvent['edition_day'] as Map<String, dynamic>? ?? const {});
    final itinerary =
        (firstEvent['itinerary'] as Map<String, dynamic>? ?? const {});
    final rawRoutePathPoints =
        (itinerary['path_points'] as List<dynamic>? ?? const []);
    final rawRoutePolyline =
        (itinerary['polyline'] as List<dynamic>? ?? const []);
    final rawRouteWaypoints =
        (itinerary['waypoints'] as List<dynamic>? ?? const []);
    final schedulePoints =
        (itinerary['schedule_points'] as List<dynamic>? ?? const []);

    DateTime? departureAt;
    if (schedulePoints.isNotEmpty &&
        schedulePoints.first is Map<String, dynamic>) {
      final raw = (schedulePoints.first as Map<String, dynamic>)['planned_at'];
      if (raw is String) {
        departureAt = _parseDateTimeWallClock(raw);
      }
    }

    return BrotherhoodDetail(
      name: (json['name'] ?? 'Hermandad') as String,
      fullName: (json['full_name'] ?? '') as String,
      history: (json['history'] ?? '') as String,
      foundationYear: (json['foundation_year'] as num?)?.toInt(),
      colorHex: (json['color_hex'] ?? '#8B1E3F') as String,
      headquartersName: (headquarters['name'] ?? '') as String,
      headquartersAddress: (headquarters['address'] ?? '') as String,
      figuresCount: (json['figures'] as List<dynamic>? ?? const []).length,
      pasosCount: (json['pasos'] as List<dynamic>? ?? const []).length,
      bandsCount: (json['bands'] as List<dynamic>? ?? const []).length,
      debutsCount: (json['debuts'] as List<dynamic>? ?? const []).length,
      newsTitles: news
          .whereType<Map<String, dynamic>>()
          .map((item) => (item['title'] ?? '') as String)
          .where((title) => title.isNotEmpty)
          .toList(growable: false),
      pasoNames: pasos
          .whereType<Map<String, dynamic>>()
          .map((item) => (item['name'] ?? '') as String)
          .where((name) => name.isNotEmpty)
          .toList(growable: false),
      dayLabel: (editionDay['name'] ?? '') as String,
      departureAt: departureAt,
      routeDescription: (itinerary['description'] ?? '') as String,
      routePoints:
          (rawRoutePathPoints.isNotEmpty
                  ? rawRoutePathPoints
                  : (rawRoutePolyline.isNotEmpty
                        ? rawRoutePolyline
                        : rawRouteWaypoints))
              .whereType<Map<String, dynamic>>()
              .map(BrotherhoodRoutePoint.fromJson)
              .where((point) => point.hasLocation)
              .toList(growable: false),
      itineraryPoints: schedulePoints
          .whereType<Map<String, dynamic>>()
          .map(BrotherhoodItineraryPoint.fromJson)
          .where((point) => point.name.isNotEmpty)
          .toList(growable: false),
    );
  }
}

class BrotherhoodRoutePoint {
  const BrotherhoodRoutePoint({
    required this.latitude,
    required this.longitude,
  });

  final double? latitude;
  final double? longitude;
  bool get hasLocation => latitude != null && longitude != null;

  factory BrotherhoodRoutePoint.fromJson(Map<String, dynamic> json) {
    return BrotherhoodRoutePoint(
      latitude: _toDouble(json['lat'] ?? json['latitude']),
      longitude: _toDouble(json['lng'] ?? json['lon'] ?? json['longitude']),
    );
  }
}

class BrotherhoodItineraryPoint {
  const BrotherhoodItineraryPoint({
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

  factory BrotherhoodItineraryPoint.fromJson(Map<String, dynamic> json) {
    final rawPlanned = json['planned_at'];
    return BrotherhoodItineraryPoint(
      name: (json['name'] ?? '') as String,
      plannedAt: rawPlanned is String
          ? _parseDateTimeWallClock(rawPlanned)
          : null,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
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
