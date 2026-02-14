import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../data/models/day_models.dart';
import '../../data/repositories/larevira_repository.dart';

class OfflineSyncController extends ChangeNotifier {
  OfflineSyncController._({
    required this.repository,
    required this.config,
    required SharedPreferencesAsync prefs,
    required this.lastSyncedAt,
  }) : _prefs = prefs;

  final LareviraRepository repository;
  final AppConfig config;
  final SharedPreferencesAsync _prefs;

  static const _lastSyncKey = 'offline_last_sync_at_v1';

  DateTime? lastSyncedAt;
  bool isSyncing = false;
  String? lastError;
  int completedSteps = 0;
  int totalSteps = 0;

  double? get progress {
    if (totalSteps <= 0) {
      return null;
    }
    return completedSteps / totalSteps;
  }

  static Future<OfflineSyncController> create({
    required LareviraRepository repository,
    required AppConfig config,
  }) async {
    final prefs = SharedPreferencesAsync();
    final rawDate = await prefs.getString(_lastSyncKey);

    return OfflineSyncController._(
      repository: repository,
      config: config,
      prefs: prefs,
      lastSyncedAt: rawDate == null ? null : DateTime.tryParse(rawDate),
    );
  }

  Future<void> maybeSyncOnStartup() async {
    if (isSyncing) {
      return;
    }

    final now = DateTime.now();
    final shouldSync = lastSyncedAt == null ||
        now.difference(lastSyncedAt!) > const Duration(hours: 12);

    if (shouldSync) {
      await syncAll();
    }
  }

  Future<void> syncAll() async {
    if (isSyncing) {
      return;
    }

    isSyncing = true;
    lastError = null;
    completedSteps = 0;
    totalSteps = 0;
    notifyListeners();

    try {
      final brotherhoods = await repository.getBrotherhoods(
        citySlug: config.citySlug,
        year: config.editionYear,
      );

      final dayModes = <String>['all', 'official'];
      final daysByMode = <String, List<DayIndexItem>>{};

      for (final mode in dayModes) {
        final days = await repository.getDays(
          citySlug: config.citySlug,
          year: config.editionYear,
          mode: mode,
        );
        daysByMode[mode] = days;
      }

      totalSteps =
          brotherhoods.length + daysByMode.values.fold<int>(0, (sum, v) => sum + v.length);
      notifyListeners();

      for (final brotherhood in brotherhoods) {
        await repository.getBrotherhoodDetail(
          citySlug: config.citySlug,
          year: config.editionYear,
          brotherhoodSlug: brotherhood.slug,
        );
        completedSteps += 1;
        notifyListeners();
      }

      for (final entry in daysByMode.entries) {
        for (final day in entry.value) {
          await repository.getDayDetail(
            citySlug: config.citySlug,
            year: config.editionYear,
            daySlug: day.slug,
            mode: entry.key,
          );
          completedSteps += 1;
          notifyListeners();
        }
      }

      lastSyncedAt = DateTime.now();
      await _prefs.setString(_lastSyncKey, lastSyncedAt!.toIso8601String());
    } catch (error) {
      lastError = error.toString();
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }
}
