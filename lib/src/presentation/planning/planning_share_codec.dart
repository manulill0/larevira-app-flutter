import 'dart:convert';

import 'planning_controller.dart';

class PlanningShareCodec {
  static const int version = 1;
  static const String _payloadKey = 'p';
  static const String _shareKey = 'share';

  static String encodePayload({
    required List<PlanningEntry> entries,
    required String citySlug,
    required int year,
    required String mode,
  }) {
    final payload = <String, dynamic>{
      'v': version,
      'city_slug': citySlug,
      'year': year,
      'mode': mode,
      'entries': entries.map((entry) => entry.toJson()).toList(growable: false),
    };

    final json = jsonEncode(payload);
    return base64UrlEncode(utf8.encode(json));
  }

  static PlanningSharePayload? decodePayload(String encoded) {
    try {
      final normalized = base64Url.normalize(encoded);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final raw = jsonDecode(decoded);
      if (raw is! Map<String, dynamic>) {
        return null;
      }

      final payloadVersion = (raw['v'] as num?)?.toInt() ?? 0;
      if (payloadVersion != version) {
        return null;
      }

      final entriesRaw = raw['entries'];
      if (entriesRaw is! List) {
        return null;
      }

      final entries = <PlanningEntry>[];
      for (final item in entriesRaw) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        entries.add(PlanningEntry.fromJson(item));
      }

      if (entries.isEmpty) {
        return null;
      }

      return PlanningSharePayload(
        citySlug: (raw['city_slug'] ?? '') as String,
        year: (raw['year'] as num?)?.toInt() ?? 0,
        mode: (raw['mode'] ?? 'all') as String,
        entries: entries,
      );
    } catch (_) {
      return null;
    }
  }

  static String? payloadFromUri(Uri uri) {
    if (uri.queryParameters.containsKey(_payloadKey)) {
      return uri.queryParameters[_payloadKey];
    }
    if (uri.fragment.isNotEmpty) {
      final fragment = Uri.splitQueryString(uri.fragment);
      return fragment[_payloadKey];
    }
    return null;
  }

  static String? shareSlugFromUri(Uri uri) {
    final queryShare = uri.queryParameters[_shareKey];
    if (queryShare != null && queryShare.isNotEmpty) {
      return queryShare;
    }

    final segments = uri.pathSegments;
    if (segments.length >= 3 &&
        segments[0] == 'planning' &&
        segments[1] == 'share') {
      return segments[2];
    }

    return null;
  }
}

class PlanningSharePayload {
  const PlanningSharePayload({
    required this.citySlug,
    required this.year,
    required this.mode,
    required this.entries,
  });

  final String citySlug;
  final int year;
  final String mode;
  final List<PlanningEntry> entries;
}
