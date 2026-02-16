import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/brotherhood_model.dart';
import '../models/brotherhood_detail_model.dart';
import '../models/day_brotherhood_model.dart';
import '../models/day_detail_model.dart';
import '../models/day_models.dart';

part 'app_database.g.dart';

class BrotherhoodsCache extends Table {
  TextColumn get citySlug => text()();
  IntColumn get year => integer()();
  TextColumn get slug => text()();
  TextColumn get name => text()();
  TextColumn get fullName => text().nullable()();
  TextColumn get colorHex => text().nullable()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {citySlug, year, slug};
}

class DaysCache extends Table {
  TextColumn get citySlug => text()();
  IntColumn get year => integer()();
  TextColumn get mode => text()();
  TextColumn get slug => text()();
  TextColumn get name => text().nullable()();
  TextColumn get startsAt => text().nullable()();
  IntColumn get processionEventsCount => integer().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().nullable()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {citySlug, year, mode, slug};
}

class DayBrotherhoodsCache extends Table {
  TextColumn get citySlug => text()();
  IntColumn get year => integer()();
  TextColumn get mode => text()();
  TextColumn get daySlug => text()();
  TextColumn get brotherhoodSlug => text()();
  TextColumn get brotherhoodName => text()();
  TextColumn get brotherhoodColorHex => text().nullable()();
  TextColumn get status => text().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {
        citySlug,
        year,
        mode,
        daySlug,
        brotherhoodSlug,
      };
}

class DayDetailsCache extends Table {
  TextColumn get citySlug => text()();
  IntColumn get year => integer()();
  TextColumn get mode => text()();
  TextColumn get daySlug => text()();
  TextColumn get payloadJson => text()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {citySlug, year, mode, daySlug};
}

class BrotherhoodDetailsCache extends Table {
  TextColumn get citySlug => text()();
  IntColumn get year => integer()();
  TextColumn get brotherhoodSlug => text()();
  TextColumn get payloadJson => text()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {citySlug, year, brotherhoodSlug};
}

@DriftDatabase(
  tables: [
    BrotherhoodsCache,
    DaysCache,
    DayBrotherhoodsCache,
    DayDetailsCache,
    BrotherhoodDetailsCache,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'larevira_cache'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(dayDetailsCache);
          }
          if (from < 3) {
            await migrator.createTable(brotherhoodDetailsCache);
          }
        },
      );

  Future<void> replaceBrotherhoods({
    required String city,
    required int yearValue,
    required List<BrotherhoodItem> items,
  }) async {
    await transaction(() async {
      await (delete(brotherhoodsCache)
            ..where((tbl) => tbl.citySlug.equals(city) & tbl.year.equals(yearValue)))
          .go();

      final now = DateTime.now().millisecondsSinceEpoch;
      await batch((batch) {
        batch.insertAll(
          brotherhoodsCache,
          items
              .map(
                (item) => BrotherhoodsCacheCompanion.insert(
                  citySlug: city,
                  year: yearValue,
                  slug: item.slug,
                  name: item.name,
                  fullName: Value(item.fullName),
                  colorHex: Value(item.colorHex),
                  updatedAtMs: now,
                ),
              )
              .toList(growable: false),
        );
      });
    });
  }

  Future<List<BrotherhoodItem>> getBrotherhoods({
    required String city,
    required int yearValue,
  }) async {
    final query = select(brotherhoodsCache)
      ..where((tbl) => tbl.citySlug.equals(city) & tbl.year.equals(yearValue))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);

    final rows = await query.get();
    return rows
        .map(
          (row) => BrotherhoodItem(
            name: row.name,
            slug: row.slug,
            fullName: row.fullName ?? '',
            colorHex: row.colorHex ?? '#8B1E3F',
          ),
        )
        .toList(growable: false);
  }

  Future<void> replaceDays({
    required String city,
    required int yearValue,
    required String modeValue,
    required List<DayIndexItem> items,
  }) async {
    await transaction(() async {
      await (delete(daysCache)
            ..where(
              (tbl) =>
                  tbl.citySlug.equals(city) &
                  tbl.year.equals(yearValue) &
                  tbl.mode.equals(modeValue),
            ))
          .go();

      final now = DateTime.now().millisecondsSinceEpoch;
      await batch((batch) {
        batch.insertAll(
          daysCache,
          items
              .map(
                (item) => DaysCacheCompanion.insert(
                  citySlug: city,
                  year: yearValue,
                  mode: modeValue,
                  slug: item.slug,
                  name: Value(item.name),
                  startsAt: Value(item.startsAt?.toIso8601String()),
                  processionEventsCount: Value(item.processionEventsCount),
                  sortOrder: const Value.absent(),
                  updatedAtMs: now,
                ),
              )
              .toList(growable: false),
        );
      });
    });
  }

  Future<List<DayIndexItem>> getDays({
    required String city,
    required int yearValue,
    required String modeValue,
  }) async {
    final query = select(daysCache)
      ..where(
        (tbl) =>
            tbl.citySlug.equals(city) &
            tbl.year.equals(yearValue) &
            tbl.mode.equals(modeValue),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.startsAt)]);

    final rows = await query.get();
    return rows
        .map(
          (row) => DayIndexItem(
            slug: row.slug,
            name: row.name ?? 'Jornada',
            startsAt: row.startsAt == null ? null : DateTime.tryParse(row.startsAt!),
            processionEventsCount: row.processionEventsCount,
          ),
        )
        .toList(growable: false);
  }

  Future<void> replaceDayBrotherhoods({
    required String city,
    required int yearValue,
    required String modeValue,
    required String daySlugValue,
    required List<DayBrotherhoodItem> items,
  }) async {
    await transaction(() async {
      await (delete(dayBrotherhoodsCache)
            ..where(
              (tbl) =>
                  tbl.citySlug.equals(city) &
                  tbl.year.equals(yearValue) &
                  tbl.mode.equals(modeValue) &
                  tbl.daySlug.equals(daySlugValue),
            ))
          .go();

      final now = DateTime.now().millisecondsSinceEpoch;
      await batch((batch) {
        batch.insertAll(
          dayBrotherhoodsCache,
          items
              .map(
                (item) => DayBrotherhoodsCacheCompanion.insert(
                  citySlug: city,
                  year: yearValue,
                  mode: modeValue,
                  daySlug: daySlugValue,
                  brotherhoodSlug: item.brotherhoodSlug,
                  brotherhoodName: item.brotherhoodName,
                  brotherhoodColorHex: Value(item.brotherhoodColorHex),
                  status: Value(item.status),
                  position: Value(item.position),
                  updatedAtMs: now,
                ),
              )
              .toList(growable: false),
        );
      });
    });
  }

  Future<List<DayBrotherhoodItem>> getDayBrotherhoods({
    required String city,
    required int yearValue,
    required String modeValue,
    required String daySlugValue,
  }) async {
    final query = select(dayBrotherhoodsCache)
      ..where(
        (tbl) =>
            tbl.citySlug.equals(city) &
            tbl.year.equals(yearValue) &
            tbl.mode.equals(modeValue) &
            tbl.daySlug.equals(daySlugValue),
      )
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.position)]);

    final rows = await query.get();
    return rows
        .map(
          (row) => DayBrotherhoodItem(
            brotherhoodSlug: row.brotherhoodSlug,
            brotherhoodName: row.brotherhoodName,
            brotherhoodColorHex: row.brotherhoodColorHex ?? '#8B1E3F',
            status: row.status ?? 'scheduled',
            position: row.position,
          ),
        )
        .toList(growable: false);
  }

  Future<void> saveDayDetail({
    required String city,
    required int yearValue,
    required String modeValue,
    required String daySlugValue,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(dayDetailsCache).insertOnConflictUpdate(
      DayDetailsCacheCompanion.insert(
        citySlug: city,
        year: yearValue,
        mode: modeValue,
        daySlug: daySlugValue,
        payloadJson: jsonEncode(payload),
        updatedAtMs: now,
      ),
    );
  }

  Future<DayDetail?> getDayDetail({
    required String city,
    required int yearValue,
    required String modeValue,
    required String daySlugValue,
  }) async {
    final query = select(dayDetailsCache)
      ..where(
        (tbl) =>
            tbl.citySlug.equals(city) &
            tbl.year.equals(yearValue) &
            tbl.mode.equals(modeValue) &
            tbl.daySlug.equals(daySlugValue),
      )
      ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      return DayDetail.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBrotherhoodDetail({
    required String city,
    required int yearValue,
    required String brotherhoodSlugValue,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(brotherhoodDetailsCache).insertOnConflictUpdate(
      BrotherhoodDetailsCacheCompanion.insert(
        citySlug: city,
        year: yearValue,
        brotherhoodSlug: brotherhoodSlugValue,
        payloadJson: jsonEncode(payload),
        updatedAtMs: now,
      ),
    );
  }

  Future<BrotherhoodDetail?> getBrotherhoodDetail({
    required String city,
    required int yearValue,
    required String brotherhoodSlugValue,
  }) async {
    final query = select(brotherhoodDetailsCache)
      ..where(
        (tbl) =>
            tbl.citySlug.equals(city) &
            tbl.year.equals(yearValue) &
            tbl.brotherhoodSlug.equals(brotherhoodSlugValue),
      )
      ..limit(1);

    final row = await query.getSingleOrNull();
    if (row == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      return BrotherhoodDetail.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAllCaches() async {
    await transaction(() async {
      await delete(brotherhoodDetailsCache).go();
      await delete(dayDetailsCache).go();
      await delete(dayBrotherhoodsCache).go();
      await delete(daysCache).go();
      await delete(brotherhoodsCache).go();
    });
  }
}
