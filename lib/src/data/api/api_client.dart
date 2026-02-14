import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient({required String baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 12),
            sendTimeout: const Duration(seconds: 10),
            responseType: ResponseType.json,
          ),
        );

  final Dio _dio;
  static final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  static const _cachePrefix = 'http_cache_get_v1:';

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final requestOptions = RequestOptions(
      path: path,
      queryParameters: queryParameters ?? const <String, dynamic>{},
    );
    final cacheKey = _cacheKeyFor(path, queryParameters);

    try {
      final response = await _requestWithRetry(
        path: path,
        queryParameters: queryParameters,
      );
      await _saveCache(cacheKey, response.data);
      return response;
    } on DioException catch (_) {
      final cached = await _readCache(cacheKey);
      if (cached != null) {
        return Response<dynamic>(
          requestOptions: requestOptions,
          data: cached,
          statusCode: 200,
          extra: const {'fromCache': true},
        );
      }
      rethrow;
    }
  }

  Future<Response<dynamic>> _requestWithRetry({
    required String path,
    Map<String, dynamic>? queryParameters,
  }) async {
    DioException? lastError;

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await _dio.get<dynamic>(path, queryParameters: queryParameters);
      } on DioException catch (error) {
        lastError = error;
        if (!_isRetryable(error) || attempt == 1) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 650));
      }
    }

    throw lastError!;
  }

  bool _isRetryable(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  String _cacheKeyFor(String path, Map<String, dynamic>? queryParameters) {
    final sortedQuery = <String, dynamic>{...(queryParameters ?? const {})};
    final orderedKeys = sortedQuery.keys.toList()..sort();
    final compact = orderedKeys
        .map((key) => '$key=${sortedQuery[key]}')
        .join('&');
    return '$_cachePrefix$path?$compact';
  }

  Future<void> _saveCache(String key, dynamic data) async {
    if (data is! Map<String, dynamic> && data is! List<dynamic>) {
      return;
    }
    await _prefs.setString(
      key,
      jsonEncode(<String, dynamic>{
        'saved_at': DateTime.now().toIso8601String(),
        'data': data,
      }),
    );
  }

  Future<dynamic> _readCache(String key) async {
    final raw = await _prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded['data'];
    } catch (_) {
      return null;
    }
  }
}
