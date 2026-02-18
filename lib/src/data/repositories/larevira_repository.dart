import '../api/api_client.dart';
import '../local/app_database.dart';
import '../models/brotherhood_detail_model.dart';
import '../models/brotherhood_model.dart';
import '../models/day_brotherhood_model.dart';
import '../models/day_detail_model.dart';
import '../models/day_models.dart';

class LareviraRepository {
  LareviraRepository({
    required ApiClient apiClient,
    required AppDatabase appDatabase,
  }) : _apiClient = apiClient,
       _appDatabase = appDatabase;

  final ApiClient _apiClient;
  final AppDatabase _appDatabase;

  Future<List<DayIndexItem>> syncDays({
    required String citySlug,
    required int year,
    required String mode,
  }) async {
    final response = await _apiClient.get(
      '/$citySlug/$year/days',
      queryParameters: {'mode': mode},
    );

    final data = response.data as Map<String, dynamic>;
    final rawList = (data['data'] as List<dynamic>? ?? const []);
    final days = rawList
        .whereType<Map<String, dynamic>>()
        .map(DayIndexItem.fromJson)
        .toList(growable: false);

    await _appDatabase.replaceDays(
      city: citySlug,
      yearValue: year,
      modeValue: mode,
      items: days,
    );

    return days;
  }

  Future<List<BrotherhoodItem>> syncBrotherhoods({
    required String citySlug,
    required int year,
  }) async {
    final response = await _apiClient.get('/$citySlug/$year/brotherhoods');

    final data = response.data as Map<String, dynamic>;
    final rawList = (data['data'] as List<dynamic>? ?? const []);
    final brotherhoods = rawList
        .whereType<Map<String, dynamic>>()
        .map(BrotherhoodItem.fromJson)
        .toList(growable: false);

    await _appDatabase.replaceBrotherhoods(
      city: citySlug,
      yearValue: year,
      items: brotherhoods,
    );

    return brotherhoods;
  }

  Future<List<DayIndexItem>> getDays({
    required String citySlug,
    required int year,
    required String mode,
  }) async {
    var local = await _appDatabase.getDays(
      city: citySlug,
      yearValue: year,
      modeValue: mode,
    );

    if (local.isNotEmpty) {
      return local;
    }

    try {
      await syncDays(citySlug: citySlug, year: year, mode: mode);
    } catch (_) {
      // Sin red: devolvemos local vacío.
    }

    local = await _appDatabase.getDays(
      city: citySlug,
      yearValue: year,
      modeValue: mode,
    );
    return local;
  }

  Future<List<BrotherhoodItem>> getBrotherhoods({
    required String citySlug,
    required int year,
  }) async {
    var local = await _appDatabase.getBrotherhoods(
      city: citySlug,
      yearValue: year,
    );

    if (local.isNotEmpty) {
      return local;
    }

    try {
      await syncBrotherhoods(citySlug: citySlug, year: year);
    } catch (_) {
      // Sin red: devolvemos local vacío.
    }

    local = await _appDatabase.getBrotherhoods(city: citySlug, yearValue: year);
    return local;
  }

  Future<void> syncDayBrotherhoods({
    required String citySlug,
    required int year,
    required String daySlug,
    required String mode,
  }) async {
    final detail = await syncDayDetail(
      citySlug: citySlug,
      year: year,
      daySlug: daySlug,
      mode: mode,
    );

    final items = detail.processionEvents
        .asMap()
        .entries
        .map(
          (entry) => DayBrotherhoodItem(
            brotherhoodSlug: entry.value.brotherhoodSlug,
            brotherhoodName: entry.value.brotherhoodName,
            brotherhoodColorHex: entry.value.brotherhoodColorHex,
            status: entry.value.status,
            position: entry.key,
          ),
        )
        .where((item) => item.brotherhoodSlug.isNotEmpty)
        .toList(growable: false);

    await _appDatabase.replaceDayBrotherhoods(
      city: citySlug,
      yearValue: year,
      modeValue: mode,
      daySlugValue: daySlug,
      items: items,
    );
  }

  Future<List<DayBrotherhoodItem>> getDayBrotherhoods({
    required String citySlug,
    required int year,
    required String daySlug,
    required String mode,
  }) async {
    var local = await _appDatabase.getDayBrotherhoods(
      city: citySlug,
      yearValue: year,
      modeValue: mode,
      daySlugValue: daySlug,
    );

    if (local.isNotEmpty) {
      return local;
    }

    try {
      await syncDayBrotherhoods(
        citySlug: citySlug,
        year: year,
        daySlug: daySlug,
        mode: mode,
      );
    } catch (_) {
      // Sin red: devolvemos local vacío.
    }

    local = await _appDatabase.getDayBrotherhoods(
      city: citySlug,
      yearValue: year,
      modeValue: mode,
      daySlugValue: daySlug,
    );
    return local;
  }

  Future<void> prefetchDayBrotherhoods({
    required String citySlug,
    required int year,
    required String mode,
    required Iterable<String> daySlugs,
  }) async {
    for (final slug in daySlugs) {
      try {
        await syncDayBrotherhoods(
          citySlug: citySlug,
          year: year,
          daySlug: slug,
          mode: mode,
        );
      } catch (_) {
        // Continuamos con el resto para no bloquear UX.
      }
    }
  }

  Future<DayDetail> getDayDetail({
    required String citySlug,
    required int year,
    required String daySlug,
    required String mode,
  }) async {
    final local = await _appDatabase.getDayDetail(
      city: citySlug,
      yearValue: year,
      modeValue: mode,
      daySlugValue: daySlug,
    );
    if (local != null) {
      return local;
    }

    try {
      return await syncDayDetail(
        citySlug: citySlug,
        year: year,
        daySlug: daySlug,
        mode: mode,
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<DayDetail> syncDayDetail({
    required String citySlug,
    required int year,
    required String daySlug,
    required String mode,
  }) async {
    final response = await _apiClient.get(
      '/$citySlug/$year/days/$daySlug',
      queryParameters: {'mode': mode},
    );

    final payload = response.data as Map<String, dynamic>;
    final data = (payload['data'] as Map<String, dynamic>? ?? const {});
    await _appDatabase.saveDayDetail(
      city: citySlug,
      yearValue: year,
      modeValue: mode,
      daySlugValue: daySlug,
      payload: data,
    );

    return DayDetail.fromJson(data);
  }

  Future<BrotherhoodDetail> getBrotherhoodDetail({
    required String citySlug,
    required int year,
    required String brotherhoodSlug,
  }) async {
    final local = await _appDatabase.getBrotherhoodDetail(
      city: citySlug,
      yearValue: year,
      brotherhoodSlugValue: brotherhoodSlug,
    );
    if (local != null) {
      return local;
    }

    return syncBrotherhoodDetail(
      citySlug: citySlug,
      year: year,
      brotherhoodSlug: brotherhoodSlug,
    );
  }

  Future<BrotherhoodDetail> syncBrotherhoodDetail({
    required String citySlug,
    required int year,
    required String brotherhoodSlug,
  }) async {
    final response = await _apiClient.get(
      '/$citySlug/$year/brotherhoods/$brotherhoodSlug',
    );

    final payload = response.data as Map<String, dynamic>;
    final data = (payload['data'] as Map<String, dynamic>? ?? const {});
    await _appDatabase.saveBrotherhoodDetail(
      city: citySlug,
      yearValue: year,
      brotherhoodSlugValue: brotherhoodSlug,
      payload: data,
    );

    return BrotherhoodDetail.fromJson(data);
  }

  Future<void> clearAllLocalCache() async {
    await _apiClient.clearHttpCache();
    await _appDatabase.clearAllCaches();
  }

  Future<String> createPlanningShare({
    required String citySlug,
    required int year,
    required String mode,
    required List<Map<String, dynamic>> entries,
  }) async {
    final response = await _apiClient.post(
      '/planning/shares',
      data: {
        'city_slug': citySlug,
        'year': year,
        'mode': mode,
        'entries': entries,
      },
    );

    final payload = response.data as Map<String, dynamic>;
    final data = (payload['data'] as Map<String, dynamic>? ?? const {});
    final shareUrl = (data['share_url'] ?? '') as String;
    if (shareUrl.isEmpty) {
      throw StateError('No se pudo obtener la URL del planning compartido.');
    }

    return shareUrl;
  }

  Future<List<Map<String, dynamic>>> getPlanningShareEntries({
    required String slug,
  }) async {
    final response = await _apiClient.get('/planning/shares/$slug');
    final payload = response.data as Map<String, dynamic>;
    final data = (payload['data'] as Map<String, dynamic>? ?? const {});
    final entries = (data['entries'] as List<dynamic>? ?? const []);

    return entries.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}
