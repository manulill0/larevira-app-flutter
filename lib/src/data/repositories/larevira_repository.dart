import '../api/api_client.dart';
import '../models/brotherhood_detail_model.dart';
import '../models/brotherhood_model.dart';
import '../models/day_detail_model.dart';
import '../models/day_models.dart';

class LareviraRepository {
  const LareviraRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<DayIndexItem>> getDays({
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

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(DayIndexItem.fromJson)
        .toList(growable: false);
  }

  Future<List<BrotherhoodItem>> getBrotherhoods({
    required String citySlug,
    required int year,
  }) async {
    final response = await _apiClient.get('/$citySlug/$year/brotherhoods');

    final data = response.data as Map<String, dynamic>;
    final rawList = (data['data'] as List<dynamic>? ?? const []);

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(BrotherhoodItem.fromJson)
        .toList(growable: false);
  }

  Future<DayDetail> getDayDetail({
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
    return DayDetail.fromJson(data);
  }

  Future<BrotherhoodDetail> getBrotherhoodDetail({
    required String citySlug,
    required int year,
    required String brotherhoodSlug,
  }) async {
    final response = await _apiClient.get(
      '/$citySlug/$year/brotherhoods/$brotherhoodSlug',
    );

    final payload = response.data as Map<String, dynamic>;
    final data = (payload['data'] as Map<String, dynamic>? ?? const {});
    return BrotherhoodDetail.fromJson(data);
  }
}
