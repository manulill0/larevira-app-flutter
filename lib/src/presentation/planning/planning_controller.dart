import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanningController extends ChangeNotifier {
  PlanningController._(this._prefs, this._entries);

  static const _storageKey = 'planning_entries_v1';

  final SharedPreferencesAsync _prefs;
  final Map<String, PlanningEntry> _entries;

  static Future<PlanningController> create() async {
    final prefs = SharedPreferencesAsync();
    final values = await prefs.getStringList(_storageKey) ?? const <String>[];
    final entries = <String, PlanningEntry>{};

    for (final raw in values) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) {
          continue;
        }
        final entry = PlanningEntry.fromJson(decoded);
        entries[entry.id] = entry;
      } catch (_) {
        // Ignoramos entradas corruptas para mantener resiliencia.
      }
    }

    return PlanningController._(prefs, entries);
  }

  List<PlanningEntry> all({String? citySlug, int? year, String? mode}) {
    final filtered = _entries.values
        .where((entry) {
          if (citySlug != null && entry.citySlug != citySlug) {
            return false;
          }
          if (year != null && entry.year != year) {
            return false;
          }
          if (mode != null && entry.mode != mode) {
            return false;
          }
          return true;
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      final byTime = a.plannedAt.compareTo(b.plannedAt);
      if (byTime != 0) {
        return byTime;
      }
      final byDay = a.daySlug.compareTo(b.daySlug);
      if (byDay != 0) {
        return byDay;
      }
      final byBrotherhood = a.brotherhoodName.compareTo(b.brotherhoodName);
      if (byBrotherhood != 0) {
        return byBrotherhood;
      }
      return a.pointName.compareTo(b.pointName);
    });
    return filtered;
  }

  List<PlanningEntry> entriesForDay({
    required String citySlug,
    required int year,
    required String mode,
    required String daySlug,
  }) {
    return all(
      citySlug: citySlug,
      year: year,
      mode: mode,
    ).where((entry) => entry.daySlug == daySlug).toList(growable: false);
  }

  bool containsEntry({
    required String citySlug,
    required int year,
    required String mode,
    required String daySlug,
    required String brotherhoodSlug,
    required String pointName,
    required DateTime plannedAt,
  }) {
    final id = PlanningEntry.composeId(
      citySlug: citySlug,
      year: year,
      mode: mode,
      daySlug: daySlug,
      brotherhoodSlug: brotherhoodSlug,
      pointName: pointName,
      plannedAt: plannedAt,
    );
    return _entries.containsKey(id);
  }

  Future<void> toggle(PlanningEntry entry) async {
    if (_entries.containsKey(entry.id)) {
      _entries.remove(entry.id);
    } else {
      _entries[entry.id] = entry;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final payload =
        _entries.values.map((entry) => jsonEncode(entry.toJson())).toList()
          ..sort();
    await _prefs.setStringList(_storageKey, payload);
  }
}

class PlanningEntry {
  const PlanningEntry({
    required this.citySlug,
    required this.year,
    required this.mode,
    required this.daySlug,
    required this.dayName,
    required this.brotherhoodSlug,
    required this.brotherhoodName,
    required this.brotherhoodColorHex,
    required this.pointName,
    required this.plannedAt,
    required this.latitude,
    required this.longitude,
  });

  final String citySlug;
  final int year;
  final String mode;
  final String daySlug;
  final String dayName;
  final String brotherhoodSlug;
  final String brotherhoodName;
  final String brotherhoodColorHex;
  final String pointName;
  final DateTime plannedAt;
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;

  String get id => composeId(
    citySlug: citySlug,
    year: year,
    mode: mode,
    daySlug: daySlug,
    brotherhoodSlug: brotherhoodSlug,
    pointName: pointName,
    plannedAt: plannedAt,
  );

  static String composeId({
    required String citySlug,
    required int year,
    required String mode,
    required String daySlug,
    required String brotherhoodSlug,
    required String pointName,
    required DateTime plannedAt,
  }) {
    final normalizedPoint = pointName.trim().toLowerCase();
    return '$citySlug|$year|$mode|$daySlug|$brotherhoodSlug|'
        '$normalizedPoint|${plannedAt.toIso8601String()}';
  }

  factory PlanningEntry.fromJson(Map<String, dynamic> json) {
    return PlanningEntry(
      citySlug: (json['city_slug'] ?? '') as String,
      year: (json['year'] as num?)?.toInt() ?? 0,
      mode: (json['mode'] ?? 'all') as String,
      daySlug: (json['day_slug'] ?? '') as String,
      dayName: (json['day_name'] ?? 'Jornada') as String,
      brotherhoodSlug: (json['brotherhood_slug'] ?? '') as String,
      brotherhoodName: (json['brotherhood_name'] ?? 'Hermandad') as String,
      brotherhoodColorHex:
          (json['brotherhood_color_hex'] ?? '#8B1E3F') as String,
      pointName: (json['point_name'] ?? 'Punto') as String,
      plannedAt:
          DateTime.tryParse((json['planned_at'] ?? '') as String) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city_slug': citySlug,
      'year': year,
      'mode': mode,
      'day_slug': daySlug,
      'day_name': dayName,
      'brotherhood_slug': brotherhoodSlug,
      'brotherhood_name': brotherhoodName,
      'brotherhood_color_hex': brotherhoodColorHex,
      'point_name': pointName,
      'planned_at': plannedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
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
