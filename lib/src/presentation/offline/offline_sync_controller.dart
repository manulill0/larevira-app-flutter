import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../data/models/brotherhood_model.dart';
import '../../data/models/day_models.dart';
import '../../data/repositories/larevira_repository.dart';

class OfflineSyncController extends ChangeNotifier {
  static const int _maxConcurrentSyncTasks = 4;
  static const int _progressNotifyStride = 3;

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
    final shouldSync =
        lastSyncedAt == null ||
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
      final brotherhoods = await repository.syncBrotherhoods(
        citySlug: config.citySlug,
        year: config.editionYear,
      );

      final dayModes = <String>['all', 'official'];
      final daysByMode = <String, List<DayIndexItem>>{};

      for (final mode in dayModes) {
        final days = await repository.syncDays(
          citySlug: config.citySlug,
          year: config.editionYear,
          mode: mode,
        );
        daysByMode[mode] = days;
      }

      totalSteps =
          brotherhoods.length +
          daysByMode.values.fold<int>(0, (sum, v) => sum + v.length);
      notifyListeners();

      await _syncBrotherhoodDetails(brotherhoods);

      final syncDayTasks = <Future<void> Function()>[];
      for (final entry in daysByMode.entries) {
        for (final day in entry.value) {
          syncDayTasks.add(() async {
            await repository.syncDayBrotherhoods(
              citySlug: config.citySlug,
              year: config.editionYear,
              daySlug: day.slug,
              mode: entry.key,
            );
          });
        }
      }
      await _runSyncTasks(syncDayTasks);

      lastSyncedAt = DateTime.now();
      await _prefs.setString(_lastSyncKey, lastSyncedAt!.toIso8601String());
    } catch (error) {
      lastError = error.toString();
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _syncBrotherhoodDetails(
    List<BrotherhoodItem> brotherhoods,
  ) async {
    await _runSyncTasks(
      brotherhoods.map((brotherhood) {
        return () => repository.syncBrotherhoodDetail(
          citySlug: config.citySlug,
          year: config.editionYear,
          brotherhoodSlug: brotherhood.slug,
        );
      }),
    );
  }

  Future<void> _runSyncTasks(Iterable<Future<void> Function()> tasks) async {
    final pending = tasks.toList(growable: false);
    if (pending.isEmpty) {
      return;
    }

    final batchSize = pending.length < _maxConcurrentSyncTasks
        ? pending.length
        : _maxConcurrentSyncTasks;

    for (var start = 0; start < pending.length; start += batchSize) {
      final end = (start + batchSize < pending.length)
          ? start + batchSize
          : pending.length;

      await Future.wait(
        pending.sublist(start, end).map((task) async {
          try {
            await task();
          } finally {
            _advanceProgress();
          }
        }),
      );
    }
  }

  void _advanceProgress() {
    completedSteps += 1;
    if (completedSteps == totalSteps ||
        completedSteps % _progressNotifyStride == 0) {
      notifyListeners();
    }
  }

  Future<void> clearLocalCache() async {
    if (isSyncing) {
      return;
    }

    lastError = null;
    completedSteps = 0;
    totalSteps = 0;
    notifyListeners();

    await repository.clearAllLocalCache();
    lastSyncedAt = null;
    await _prefs.remove(_lastSyncKey);
    notifyListeners();
  }
}
