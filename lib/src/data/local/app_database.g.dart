// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BrotherhoodsCacheTable extends BrotherhoodsCache
    with TableInfo<$BrotherhoodsCacheTable, BrotherhoodsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BrotherhoodsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _citySlugMeta = const VerificationMeta(
    'citySlug',
  );
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
    'city_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    citySlug,
    year,
    slug,
    name,
    fullName,
    colorHex,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'brotherhoods_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<BrotherhoodsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_slug')) {
      context.handle(
        _citySlugMeta,
        citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {citySlug, year, slug};
  @override
  BrotherhoodsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BrotherhoodsCacheData(
      citySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_slug'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      ),
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $BrotherhoodsCacheTable createAlias(String alias) {
    return $BrotherhoodsCacheTable(attachedDatabase, alias);
  }
}

class BrotherhoodsCacheData extends DataClass
    implements Insertable<BrotherhoodsCacheData> {
  final String citySlug;
  final int year;
  final String slug;
  final String name;
  final String? fullName;
  final String? colorHex;
  final int updatedAtMs;
  const BrotherhoodsCacheData({
    required this.citySlug,
    required this.year,
    required this.slug,
    required this.name,
    this.fullName,
    this.colorHex,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_slug'] = Variable<String>(citySlug);
    map['year'] = Variable<int>(year);
    map['slug'] = Variable<String>(slug);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  BrotherhoodsCacheCompanion toCompanion(bool nullToAbsent) {
    return BrotherhoodsCacheCompanion(
      citySlug: Value(citySlug),
      year: Value(year),
      slug: Value(slug),
      name: Value(name),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory BrotherhoodsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BrotherhoodsCacheData(
      citySlug: serializer.fromJson<String>(json['citySlug']),
      year: serializer.fromJson<int>(json['year']),
      slug: serializer.fromJson<String>(json['slug']),
      name: serializer.fromJson<String>(json['name']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'citySlug': serializer.toJson<String>(citySlug),
      'year': serializer.toJson<int>(year),
      'slug': serializer.toJson<String>(slug),
      'name': serializer.toJson<String>(name),
      'fullName': serializer.toJson<String?>(fullName),
      'colorHex': serializer.toJson<String?>(colorHex),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  BrotherhoodsCacheData copyWith({
    String? citySlug,
    int? year,
    String? slug,
    String? name,
    Value<String?> fullName = const Value.absent(),
    Value<String?> colorHex = const Value.absent(),
    int? updatedAtMs,
  }) => BrotherhoodsCacheData(
    citySlug: citySlug ?? this.citySlug,
    year: year ?? this.year,
    slug: slug ?? this.slug,
    name: name ?? this.name,
    fullName: fullName.present ? fullName.value : this.fullName,
    colorHex: colorHex.present ? colorHex.value : this.colorHex,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  BrotherhoodsCacheData copyWithCompanion(BrotherhoodsCacheCompanion data) {
    return BrotherhoodsCacheData(
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      year: data.year.present ? data.year.value : this.year,
      slug: data.slug.present ? data.slug.value : this.slug,
      name: data.name.present ? data.name.value : this.name,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BrotherhoodsCacheData(')
          ..write('citySlug: $citySlug, ')
          ..write('year: $year, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('fullName: $fullName, ')
          ..write('colorHex: $colorHex, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(citySlug, year, slug, name, fullName, colorHex, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BrotherhoodsCacheData &&
          other.citySlug == this.citySlug &&
          other.year == this.year &&
          other.slug == this.slug &&
          other.name == this.name &&
          other.fullName == this.fullName &&
          other.colorHex == this.colorHex &&
          other.updatedAtMs == this.updatedAtMs);
}

class BrotherhoodsCacheCompanion
    extends UpdateCompanion<BrotherhoodsCacheData> {
  final Value<String> citySlug;
  final Value<int> year;
  final Value<String> slug;
  final Value<String> name;
  final Value<String?> fullName;
  final Value<String?> colorHex;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const BrotherhoodsCacheCompanion({
    this.citySlug = const Value.absent(),
    this.year = const Value.absent(),
    this.slug = const Value.absent(),
    this.name = const Value.absent(),
    this.fullName = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BrotherhoodsCacheCompanion.insert({
    required String citySlug,
    required int year,
    required String slug,
    required String name,
    this.fullName = const Value.absent(),
    this.colorHex = const Value.absent(),
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : citySlug = Value(citySlug),
       year = Value(year),
       slug = Value(slug),
       name = Value(name),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<BrotherhoodsCacheData> custom({
    Expression<String>? citySlug,
    Expression<int>? year,
    Expression<String>? slug,
    Expression<String>? name,
    Expression<String>? fullName,
    Expression<String>? colorHex,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (citySlug != null) 'city_slug': citySlug,
      if (year != null) 'year': year,
      if (slug != null) 'slug': slug,
      if (name != null) 'name': name,
      if (fullName != null) 'full_name': fullName,
      if (colorHex != null) 'color_hex': colorHex,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BrotherhoodsCacheCompanion copyWith({
    Value<String>? citySlug,
    Value<int>? year,
    Value<String>? slug,
    Value<String>? name,
    Value<String?>? fullName,
    Value<String?>? colorHex,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return BrotherhoodsCacheCompanion(
      citySlug: citySlug ?? this.citySlug,
      year: year ?? this.year,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      colorHex: colorHex ?? this.colorHex,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BrotherhoodsCacheCompanion(')
          ..write('citySlug: $citySlug, ')
          ..write('year: $year, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('fullName: $fullName, ')
          ..write('colorHex: $colorHex, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DaysCacheTable extends DaysCache
    with TableInfo<$DaysCacheTable, DaysCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DaysCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _citySlugMeta = const VerificationMeta(
    'citySlug',
  );
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
    'city_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<String> startsAt = GeneratedColumn<String>(
    'starts_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processionEventsCountMeta =
      const VerificationMeta('processionEventsCount');
  @override
  late final GeneratedColumn<int> processionEventsCount = GeneratedColumn<int>(
    'procession_events_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    citySlug,
    year,
    mode,
    slug,
    name,
    startsAt,
    processionEventsCount,
    sortOrder,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'days_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<DaysCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_slug')) {
      context.handle(
        _citySlugMeta,
        citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    }
    if (data.containsKey('procession_events_count')) {
      context.handle(
        _processionEventsCountMeta,
        processionEventsCount.isAcceptableOrUnknown(
          data['procession_events_count']!,
          _processionEventsCountMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {citySlug, year, mode, slug};
  @override
  DaysCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DaysCacheData(
      citySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_slug'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}starts_at'],
      ),
      processionEventsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}procession_events_count'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $DaysCacheTable createAlias(String alias) {
    return $DaysCacheTable(attachedDatabase, alias);
  }
}

class DaysCacheData extends DataClass implements Insertable<DaysCacheData> {
  final String citySlug;
  final int year;
  final String mode;
  final String slug;
  final String? name;
  final String? startsAt;
  final int processionEventsCount;
  final int? sortOrder;
  final int updatedAtMs;
  const DaysCacheData({
    required this.citySlug,
    required this.year,
    required this.mode,
    required this.slug,
    this.name,
    this.startsAt,
    required this.processionEventsCount,
    this.sortOrder,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_slug'] = Variable<String>(citySlug);
    map['year'] = Variable<int>(year);
    map['mode'] = Variable<String>(mode);
    map['slug'] = Variable<String>(slug);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || startsAt != null) {
      map['starts_at'] = Variable<String>(startsAt);
    }
    map['procession_events_count'] = Variable<int>(processionEventsCount);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  DaysCacheCompanion toCompanion(bool nullToAbsent) {
    return DaysCacheCompanion(
      citySlug: Value(citySlug),
      year: Value(year),
      mode: Value(mode),
      slug: Value(slug),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      startsAt: startsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startsAt),
      processionEventsCount: Value(processionEventsCount),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory DaysCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DaysCacheData(
      citySlug: serializer.fromJson<String>(json['citySlug']),
      year: serializer.fromJson<int>(json['year']),
      mode: serializer.fromJson<String>(json['mode']),
      slug: serializer.fromJson<String>(json['slug']),
      name: serializer.fromJson<String?>(json['name']),
      startsAt: serializer.fromJson<String?>(json['startsAt']),
      processionEventsCount: serializer.fromJson<int>(
        json['processionEventsCount'],
      ),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'citySlug': serializer.toJson<String>(citySlug),
      'year': serializer.toJson<int>(year),
      'mode': serializer.toJson<String>(mode),
      'slug': serializer.toJson<String>(slug),
      'name': serializer.toJson<String?>(name),
      'startsAt': serializer.toJson<String?>(startsAt),
      'processionEventsCount': serializer.toJson<int>(processionEventsCount),
      'sortOrder': serializer.toJson<int?>(sortOrder),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  DaysCacheData copyWith({
    String? citySlug,
    int? year,
    String? mode,
    String? slug,
    Value<String?> name = const Value.absent(),
    Value<String?> startsAt = const Value.absent(),
    int? processionEventsCount,
    Value<int?> sortOrder = const Value.absent(),
    int? updatedAtMs,
  }) => DaysCacheData(
    citySlug: citySlug ?? this.citySlug,
    year: year ?? this.year,
    mode: mode ?? this.mode,
    slug: slug ?? this.slug,
    name: name.present ? name.value : this.name,
    startsAt: startsAt.present ? startsAt.value : this.startsAt,
    processionEventsCount: processionEventsCount ?? this.processionEventsCount,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  DaysCacheData copyWithCompanion(DaysCacheCompanion data) {
    return DaysCacheData(
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      year: data.year.present ? data.year.value : this.year,
      mode: data.mode.present ? data.mode.value : this.mode,
      slug: data.slug.present ? data.slug.value : this.slug,
      name: data.name.present ? data.name.value : this.name,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      processionEventsCount: data.processionEventsCount.present
          ? data.processionEventsCount.value
          : this.processionEventsCount,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DaysCacheData(')
          ..write('citySlug: $citySlug, ')
          ..write('year: $year, ')
          ..write('mode: $mode, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('startsAt: $startsAt, ')
          ..write('processionEventsCount: $processionEventsCount, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    citySlug,
    year,
    mode,
    slug,
    name,
    startsAt,
    processionEventsCount,
    sortOrder,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DaysCacheData &&
          other.citySlug == this.citySlug &&
          other.year == this.year &&
          other.mode == this.mode &&
          other.slug == this.slug &&
          other.name == this.name &&
          other.startsAt == this.startsAt &&
          other.processionEventsCount == this.processionEventsCount &&
          other.sortOrder == this.sortOrder &&
          other.updatedAtMs == this.updatedAtMs);
}

class DaysCacheCompanion extends UpdateCompanion<DaysCacheData> {
  final Value<String> citySlug;
  final Value<int> year;
  final Value<String> mode;
  final Value<String> slug;
  final Value<String?> name;
  final Value<String?> startsAt;
  final Value<int> processionEventsCount;
  final Value<int?> sortOrder;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const DaysCacheCompanion({
    this.citySlug = const Value.absent(),
    this.year = const Value.absent(),
    this.mode = const Value.absent(),
    this.slug = const Value.absent(),
    this.name = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.processionEventsCount = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DaysCacheCompanion.insert({
    required String citySlug,
    required int year,
    required String mode,
    required String slug,
    this.name = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.processionEventsCount = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : citySlug = Value(citySlug),
       year = Value(year),
       mode = Value(mode),
       slug = Value(slug),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<DaysCacheData> custom({
    Expression<String>? citySlug,
    Expression<int>? year,
    Expression<String>? mode,
    Expression<String>? slug,
    Expression<String>? name,
    Expression<String>? startsAt,
    Expression<int>? processionEventsCount,
    Expression<int>? sortOrder,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (citySlug != null) 'city_slug': citySlug,
      if (year != null) 'year': year,
      if (mode != null) 'mode': mode,
      if (slug != null) 'slug': slug,
      if (name != null) 'name': name,
      if (startsAt != null) 'starts_at': startsAt,
      if (processionEventsCount != null)
        'procession_events_count': processionEventsCount,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DaysCacheCompanion copyWith({
    Value<String>? citySlug,
    Value<int>? year,
    Value<String>? mode,
    Value<String>? slug,
    Value<String?>? name,
    Value<String?>? startsAt,
    Value<int>? processionEventsCount,
    Value<int?>? sortOrder,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return DaysCacheCompanion(
      citySlug: citySlug ?? this.citySlug,
      year: year ?? this.year,
      mode: mode ?? this.mode,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      startsAt: startsAt ?? this.startsAt,
      processionEventsCount:
          processionEventsCount ?? this.processionEventsCount,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<String>(startsAt.value);
    }
    if (processionEventsCount.present) {
      map['procession_events_count'] = Variable<int>(
        processionEventsCount.value,
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DaysCacheCompanion(')
          ..write('citySlug: $citySlug, ')
          ..write('year: $year, ')
          ..write('mode: $mode, ')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('startsAt: $startsAt, ')
          ..write('processionEventsCount: $processionEventsCount, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayBrotherhoodsCacheTable extends DayBrotherhoodsCache
    with TableInfo<$DayBrotherhoodsCacheTable, DayBrotherhoodsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayBrotherhoodsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _citySlugMeta = const VerificationMeta(
    'citySlug',
  );
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
    'city_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daySlugMeta = const VerificationMeta(
    'daySlug',
  );
  @override
  late final GeneratedColumn<String> daySlug = GeneratedColumn<String>(
    'day_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brotherhoodSlugMeta = const VerificationMeta(
    'brotherhoodSlug',
  );
  @override
  late final GeneratedColumn<String> brotherhoodSlug = GeneratedColumn<String>(
    'brotherhood_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brotherhoodNameMeta = const VerificationMeta(
    'brotherhoodName',
  );
  @override
  late final GeneratedColumn<String> brotherhoodName = GeneratedColumn<String>(
    'brotherhood_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brotherhoodColorHexMeta =
      const VerificationMeta('brotherhoodColorHex');
  @override
  late final GeneratedColumn<String> brotherhoodColorHex =
      GeneratedColumn<String>(
        'brotherhood_color_hex',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    citySlug,
    year,
    mode,
    daySlug,
    brotherhoodSlug,
    brotherhoodName,
    brotherhoodColorHex,
    status,
    position,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_brotherhoods_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayBrotherhoodsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_slug')) {
      context.handle(
        _citySlugMeta,
        citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('day_slug')) {
      context.handle(
        _daySlugMeta,
        daySlug.isAcceptableOrUnknown(data['day_slug']!, _daySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_daySlugMeta);
    }
    if (data.containsKey('brotherhood_slug')) {
      context.handle(
        _brotherhoodSlugMeta,
        brotherhoodSlug.isAcceptableOrUnknown(
          data['brotherhood_slug']!,
          _brotherhoodSlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_brotherhoodSlugMeta);
    }
    if (data.containsKey('brotherhood_name')) {
      context.handle(
        _brotherhoodNameMeta,
        brotherhoodName.isAcceptableOrUnknown(
          data['brotherhood_name']!,
          _brotherhoodNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_brotherhoodNameMeta);
    }
    if (data.containsKey('brotherhood_color_hex')) {
      context.handle(
        _brotherhoodColorHexMeta,
        brotherhoodColorHex.isAcceptableOrUnknown(
          data['brotherhood_color_hex']!,
          _brotherhoodColorHexMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    citySlug,
    year,
    mode,
    daySlug,
    brotherhoodSlug,
  };
  @override
  DayBrotherhoodsCacheData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayBrotherhoodsCacheData(
      citySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_slug'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      daySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_slug'],
      )!,
      brotherhoodSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_slug'],
      )!,
      brotherhoodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_name'],
      )!,
      brotherhoodColorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_color_hex'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $DayBrotherhoodsCacheTable createAlias(String alias) {
    return $DayBrotherhoodsCacheTable(attachedDatabase, alias);
  }
}

class DayBrotherhoodsCacheData extends DataClass
    implements Insertable<DayBrotherhoodsCacheData> {
  final String citySlug;
  final int year;
  final String mode;
  final String daySlug;
  final String brotherhoodSlug;
  final String brotherhoodName;
  final String? brotherhoodColorHex;
  final String? status;
  final int position;
  final int updatedAtMs;
  const DayBrotherhoodsCacheData({
    required this.citySlug,
    required this.year,
    required this.mode,
    required this.daySlug,
    required this.brotherhoodSlug,
    required this.brotherhoodName,
    this.brotherhoodColorHex,
    this.status,
    required this.position,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_slug'] = Variable<String>(citySlug);
    map['year'] = Variable<int>(year);
    map['mode'] = Variable<String>(mode);
    map['day_slug'] = Variable<String>(daySlug);
    map['brotherhood_slug'] = Variable<String>(brotherhoodSlug);
    map['brotherhood_name'] = Variable<String>(brotherhoodName);
    if (!nullToAbsent || brotherhoodColorHex != null) {
      map['brotherhood_color_hex'] = Variable<String>(brotherhoodColorHex);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['position'] = Variable<int>(position);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  DayBrotherhoodsCacheCompanion toCompanion(bool nullToAbsent) {
    return DayBrotherhoodsCacheCompanion(
      citySlug: Value(citySlug),
      year: Value(year),
      mode: Value(mode),
      daySlug: Value(daySlug),
      brotherhoodSlug: Value(brotherhoodSlug),
      brotherhoodName: Value(brotherhoodName),
      brotherhoodColorHex: brotherhoodColorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(brotherhoodColorHex),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      position: Value(position),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory DayBrotherhoodsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayBrotherhoodsCacheData(
      citySlug: serializer.fromJson<String>(json['citySlug']),
      year: serializer.fromJson<int>(json['year']),
      mode: serializer.fromJson<String>(json['mode']),
      daySlug: serializer.fromJson<String>(json['daySlug']),
      brotherhoodSlug: serializer.fromJson<String>(json['brotherhoodSlug']),
      brotherhoodName: serializer.fromJson<String>(json['brotherhoodName']),
      brotherhoodColorHex: serializer.fromJson<String?>(
        json['brotherhoodColorHex'],
      ),
      status: serializer.fromJson<String?>(json['status']),
      position: serializer.fromJson<int>(json['position']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'citySlug': serializer.toJson<String>(citySlug),
      'year': serializer.toJson<int>(year),
      'mode': serializer.toJson<String>(mode),
      'daySlug': serializer.toJson<String>(daySlug),
      'brotherhoodSlug': serializer.toJson<String>(brotherhoodSlug),
      'brotherhoodName': serializer.toJson<String>(brotherhoodName),
      'brotherhoodColorHex': serializer.toJson<String?>(brotherhoodColorHex),
      'status': serializer.toJson<String?>(status),
      'position': serializer.toJson<int>(position),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  DayBrotherhoodsCacheData copyWith({
    String? citySlug,
    int? year,
    String? mode,
    String? daySlug,
    String? brotherhoodSlug,
    String? brotherhoodName,
    Value<String?> brotherhoodColorHex = const Value.absent(),
    Value<String?> status = const Value.absent(),
    int? position,
    int? updatedAtMs,
  }) => DayBrotherhoodsCacheData(
    citySlug: citySlug ?? this.citySlug,
    year: year ?? this.year,
    mode: mode ?? this.mode,
    daySlug: daySlug ?? this.daySlug,
    brotherhoodSlug: brotherhoodSlug ?? this.brotherhoodSlug,
    brotherhoodName: brotherhoodName ?? this.brotherhoodName,
    brotherhoodColorHex: brotherhoodColorHex.present
        ? brotherhoodColorHex.value
        : this.brotherhoodColorHex,
    status: status.present ? status.value : this.status,
    position: position ?? this.position,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  DayBrotherhoodsCacheData copyWithCompanion(
    DayBrotherhoodsCacheCompanion data,
  ) {
    return DayBrotherhoodsCacheData(
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      year: data.year.present ? data.year.value : this.year,
      mode: data.mode.present ? data.mode.value : this.mode,
      daySlug: data.daySlug.present ? data.daySlug.value : this.daySlug,
      brotherhoodSlug: data.brotherhoodSlug.present
          ? data.brotherhoodSlug.value
          : this.brotherhoodSlug,
      brotherhoodName: data.brotherhoodName.present
          ? data.brotherhoodName.value
          : this.brotherhoodName,
      brotherhoodColorHex: data.brotherhoodColorHex.present
          ? data.brotherhoodColorHex.value
          : this.brotherhoodColorHex,
      status: data.status.present ? data.status.value : this.status,
      position: data.position.present ? data.position.value : this.position,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayBrotherhoodsCacheData(')
          ..write('citySlug: $citySlug, ')
          ..write('year: $year, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('brotherhoodSlug: $brotherhoodSlug, ')
          ..write('brotherhoodName: $brotherhoodName, ')
          ..write('brotherhoodColorHex: $brotherhoodColorHex, ')
          ..write('status: $status, ')
          ..write('position: $position, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    citySlug,
    year,
    mode,
    daySlug,
    brotherhoodSlug,
    brotherhoodName,
    brotherhoodColorHex,
    status,
    position,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayBrotherhoodsCacheData &&
          other.citySlug == this.citySlug &&
          other.year == this.year &&
          other.mode == this.mode &&
          other.daySlug == this.daySlug &&
          other.brotherhoodSlug == this.brotherhoodSlug &&
          other.brotherhoodName == this.brotherhoodName &&
          other.brotherhoodColorHex == this.brotherhoodColorHex &&
          other.status == this.status &&
          other.position == this.position &&
          other.updatedAtMs == this.updatedAtMs);
}

class DayBrotherhoodsCacheCompanion
    extends UpdateCompanion<DayBrotherhoodsCacheData> {
  final Value<String> citySlug;
  final Value<int> year;
  final Value<String> mode;
  final Value<String> daySlug;
  final Value<String> brotherhoodSlug;
  final Value<String> brotherhoodName;
  final Value<String?> brotherhoodColorHex;
  final Value<String?> status;
  final Value<int> position;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const DayBrotherhoodsCacheCompanion({
    this.citySlug = const Value.absent(),
    this.year = const Value.absent(),
    this.mode = const Value.absent(),
    this.daySlug = const Value.absent(),
    this.brotherhoodSlug = const Value.absent(),
    this.brotherhoodName = const Value.absent(),
    this.brotherhoodColorHex = const Value.absent(),
    this.status = const Value.absent(),
    this.position = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayBrotherhoodsCacheCompanion.insert({
    required String citySlug,
    required int year,
    required String mode,
    required String daySlug,
    required String brotherhoodSlug,
    required String brotherhoodName,
    this.brotherhoodColorHex = const Value.absent(),
    this.status = const Value.absent(),
    this.position = const Value.absent(),
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : citySlug = Value(citySlug),
       year = Value(year),
       mode = Value(mode),
       daySlug = Value(daySlug),
       brotherhoodSlug = Value(brotherhoodSlug),
       brotherhoodName = Value(brotherhoodName),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<DayBrotherhoodsCacheData> custom({
    Expression<String>? citySlug,
    Expression<int>? year,
    Expression<String>? mode,
    Expression<String>? daySlug,
    Expression<String>? brotherhoodSlug,
    Expression<String>? brotherhoodName,
    Expression<String>? brotherhoodColorHex,
    Expression<String>? status,
    Expression<int>? position,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (citySlug != null) 'city_slug': citySlug,
      if (year != null) 'year': year,
      if (mode != null) 'mode': mode,
      if (daySlug != null) 'day_slug': daySlug,
      if (brotherhoodSlug != null) 'brotherhood_slug': brotherhoodSlug,
      if (brotherhoodName != null) 'brotherhood_name': brotherhoodName,
      if (brotherhoodColorHex != null)
        'brotherhood_color_hex': brotherhoodColorHex,
      if (status != null) 'status': status,
      if (position != null) 'position': position,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayBrotherhoodsCacheCompanion copyWith({
    Value<String>? citySlug,
    Value<int>? year,
    Value<String>? mode,
    Value<String>? daySlug,
    Value<String>? brotherhoodSlug,
    Value<String>? brotherhoodName,
    Value<String?>? brotherhoodColorHex,
    Value<String?>? status,
    Value<int>? position,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return DayBrotherhoodsCacheCompanion(
      citySlug: citySlug ?? this.citySlug,
      year: year ?? this.year,
      mode: mode ?? this.mode,
      daySlug: daySlug ?? this.daySlug,
      brotherhoodSlug: brotherhoodSlug ?? this.brotherhoodSlug,
      brotherhoodName: brotherhoodName ?? this.brotherhoodName,
      brotherhoodColorHex: brotherhoodColorHex ?? this.brotherhoodColorHex,
      status: status ?? this.status,
      position: position ?? this.position,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (daySlug.present) {
      map['day_slug'] = Variable<String>(daySlug.value);
    }
    if (brotherhoodSlug.present) {
      map['brotherhood_slug'] = Variable<String>(brotherhoodSlug.value);
    }
    if (brotherhoodName.present) {
      map['brotherhood_name'] = Variable<String>(brotherhoodName.value);
    }
    if (brotherhoodColorHex.present) {
      map['brotherhood_color_hex'] = Variable<String>(
        brotherhoodColorHex.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayBrotherhoodsCacheCompanion(')
          ..write('citySlug: $citySlug, ')
          ..write('year: $year, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('brotherhoodSlug: $brotherhoodSlug, ')
          ..write('brotherhoodName: $brotherhoodName, ')
          ..write('brotherhoodColorHex: $brotherhoodColorHex, ')
          ..write('status: $status, ')
          ..write('position: $position, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayDetailsCacheTable extends DayDetailsCache
    with TableInfo<$DayDetailsCacheTable, DayDetailsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayDetailsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _citySlugMeta = const VerificationMeta(
    'citySlug',
  );
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
    'city_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daySlugMeta = const VerificationMeta(
    'daySlug',
  );
  @override
  late final GeneratedColumn<String> daySlug = GeneratedColumn<String>(
    'day_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    citySlug,
    year,
    mode,
    daySlug,
    payloadJson,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_details_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayDetailsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_slug')) {
      context.handle(
        _citySlugMeta,
        citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('day_slug')) {
      context.handle(
        _daySlugMeta,
        daySlug.isAcceptableOrUnknown(data['day_slug']!, _daySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_daySlugMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {citySlug, year, mode, daySlug};
  @override
  DayDetailsCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayDetailsCacheData(
      citySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_slug'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      daySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_slug'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $DayDetailsCacheTable createAlias(String alias) {
    return $DayDetailsCacheTable(attachedDatabase, alias);
  }
}

class DayDetailsCacheData extends DataClass
    implements Insertable<DayDetailsCacheData> {
  final String citySlug;
  final int year;
  final String mode;
  final String daySlug;
  final String payloadJson;
  final int updatedAtMs;
  const DayDetailsCacheData({
    required this.citySlug,
    required this.year,
    required this.mode,
    required this.daySlug,
    required this.payloadJson,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_slug'] = Variable<String>(citySlug);
    map['year'] = Variable<int>(year);
    map['mode'] = Variable<String>(mode);
    map['day_slug'] = Variable<String>(daySlug);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  DayDetailsCacheCompanion toCompanion(bool nullToAbsent) {
    return DayDetailsCacheCompanion(
      citySlug: Value(citySlug),
      year: Value(year),
      mode: Value(mode),
      daySlug: Value(daySlug),
      payloadJson: Value(payloadJson),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory DayDetailsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayDetailsCacheData(
      citySlug: serializer.fromJson<String>(json['citySlug']),
      year: serializer.fromJson<int>(json['year']),
      mode: serializer.fromJson<String>(json['mode']),
      daySlug: serializer.fromJson<String>(json['daySlug']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'citySlug': serializer.toJson<String>(citySlug),
      'year': serializer.toJson<int>(year),
      'mode': serializer.toJson<String>(mode),
      'daySlug': serializer.toJson<String>(daySlug),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  DayDetailsCacheData copyWith({
    String? citySlug,
    int? year,
    String? mode,
    String? daySlug,
    String? payloadJson,
    int? updatedAtMs,
  }) => DayDetailsCacheData(
    citySlug: citySlug ?? this.citySlug,
    year: year ?? this.year,
    mode: mode ?? this.mode,
    daySlug: daySlug ?? this.daySlug,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  DayDetailsCacheData copyWithCompanion(DayDetailsCacheCompanion data) {
    return DayDetailsCacheData(
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      year: data.year.present ? data.year.value : this.year,
      mode: data.mode.present ? data.mode.value : this.mode,
      daySlug: data.daySlug.present ? data.daySlug.value : this.daySlug,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayDetailsCacheData(')
          ..write('citySlug: $citySlug, ')
          ..write('year: $year, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(citySlug, year, mode, daySlug, payloadJson, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayDetailsCacheData &&
          other.citySlug == this.citySlug &&
          other.year == this.year &&
          other.mode == this.mode &&
          other.daySlug == this.daySlug &&
          other.payloadJson == this.payloadJson &&
          other.updatedAtMs == this.updatedAtMs);
}

class DayDetailsCacheCompanion extends UpdateCompanion<DayDetailsCacheData> {
  final Value<String> citySlug;
  final Value<int> year;
  final Value<String> mode;
  final Value<String> daySlug;
  final Value<String> payloadJson;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const DayDetailsCacheCompanion({
    this.citySlug = const Value.absent(),
    this.year = const Value.absent(),
    this.mode = const Value.absent(),
    this.daySlug = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayDetailsCacheCompanion.insert({
    required String citySlug,
    required int year,
    required String mode,
    required String daySlug,
    required String payloadJson,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : citySlug = Value(citySlug),
       year = Value(year),
       mode = Value(mode),
       daySlug = Value(daySlug),
       payloadJson = Value(payloadJson),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<DayDetailsCacheData> custom({
    Expression<String>? citySlug,
    Expression<int>? year,
    Expression<String>? mode,
    Expression<String>? daySlug,
    Expression<String>? payloadJson,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (citySlug != null) 'city_slug': citySlug,
      if (year != null) 'year': year,
      if (mode != null) 'mode': mode,
      if (daySlug != null) 'day_slug': daySlug,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayDetailsCacheCompanion copyWith({
    Value<String>? citySlug,
    Value<int>? year,
    Value<String>? mode,
    Value<String>? daySlug,
    Value<String>? payloadJson,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return DayDetailsCacheCompanion(
      citySlug: citySlug ?? this.citySlug,
      year: year ?? this.year,
      mode: mode ?? this.mode,
      daySlug: daySlug ?? this.daySlug,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (daySlug.present) {
      map['day_slug'] = Variable<String>(daySlug.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayDetailsCacheCompanion(')
          ..write('citySlug: $citySlug, ')
          ..write('year: $year, ')
          ..write('mode: $mode, ')
          ..write('daySlug: $daySlug, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BrotherhoodDetailsCacheTable extends BrotherhoodDetailsCache
    with TableInfo<$BrotherhoodDetailsCacheTable, BrotherhoodDetailsCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BrotherhoodDetailsCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _citySlugMeta = const VerificationMeta(
    'citySlug',
  );
  @override
  late final GeneratedColumn<String> citySlug = GeneratedColumn<String>(
    'city_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brotherhoodSlugMeta = const VerificationMeta(
    'brotherhoodSlug',
  );
  @override
  late final GeneratedColumn<String> brotherhoodSlug = GeneratedColumn<String>(
    'brotherhood_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    citySlug,
    year,
    brotherhoodSlug,
    payloadJson,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'brotherhood_details_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<BrotherhoodDetailsCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_slug')) {
      context.handle(
        _citySlugMeta,
        citySlug.isAcceptableOrUnknown(data['city_slug']!, _citySlugMeta),
      );
    } else if (isInserting) {
      context.missing(_citySlugMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('brotherhood_slug')) {
      context.handle(
        _brotherhoodSlugMeta,
        brotherhoodSlug.isAcceptableOrUnknown(
          data['brotherhood_slug']!,
          _brotherhoodSlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_brotherhoodSlugMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {citySlug, year, brotherhoodSlug};
  @override
  BrotherhoodDetailsCacheData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BrotherhoodDetailsCacheData(
      citySlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city_slug'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      brotherhoodSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brotherhood_slug'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $BrotherhoodDetailsCacheTable createAlias(String alias) {
    return $BrotherhoodDetailsCacheTable(attachedDatabase, alias);
  }
}

class BrotherhoodDetailsCacheData extends DataClass
    implements Insertable<BrotherhoodDetailsCacheData> {
  final String citySlug;
  final int year;
  final String brotherhoodSlug;
  final String payloadJson;
  final int updatedAtMs;
  const BrotherhoodDetailsCacheData({
    required this.citySlug,
    required this.year,
    required this.brotherhoodSlug,
    required this.payloadJson,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_slug'] = Variable<String>(citySlug);
    map['year'] = Variable<int>(year);
    map['brotherhood_slug'] = Variable<String>(brotherhoodSlug);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  BrotherhoodDetailsCacheCompanion toCompanion(bool nullToAbsent) {
    return BrotherhoodDetailsCacheCompanion(
      citySlug: Value(citySlug),
      year: Value(year),
      brotherhoodSlug: Value(brotherhoodSlug),
      payloadJson: Value(payloadJson),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory BrotherhoodDetailsCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BrotherhoodDetailsCacheData(
      citySlug: serializer.fromJson<String>(json['citySlug']),
      year: serializer.fromJson<int>(json['year']),
      brotherhoodSlug: serializer.fromJson<String>(json['brotherhoodSlug']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'citySlug': serializer.toJson<String>(citySlug),
      'year': serializer.toJson<int>(year),
      'brotherhoodSlug': serializer.toJson<String>(brotherhoodSlug),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  BrotherhoodDetailsCacheData copyWith({
    String? citySlug,
    int? year,
    String? brotherhoodSlug,
    String? payloadJson,
    int? updatedAtMs,
  }) => BrotherhoodDetailsCacheData(
    citySlug: citySlug ?? this.citySlug,
    year: year ?? this.year,
    brotherhoodSlug: brotherhoodSlug ?? this.brotherhoodSlug,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  BrotherhoodDetailsCacheData copyWithCompanion(
    BrotherhoodDetailsCacheCompanion data,
  ) {
    return BrotherhoodDetailsCacheData(
      citySlug: data.citySlug.present ? data.citySlug.value : this.citySlug,
      year: data.year.present ? data.year.value : this.year,
      brotherhoodSlug: data.brotherhoodSlug.present
          ? data.brotherhoodSlug.value
          : this.brotherhoodSlug,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BrotherhoodDetailsCacheData(')
          ..write('citySlug: $citySlug, ')
          ..write('year: $year, ')
          ..write('brotherhoodSlug: $brotherhoodSlug, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(citySlug, year, brotherhoodSlug, payloadJson, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BrotherhoodDetailsCacheData &&
          other.citySlug == this.citySlug &&
          other.year == this.year &&
          other.brotherhoodSlug == this.brotherhoodSlug &&
          other.payloadJson == this.payloadJson &&
          other.updatedAtMs == this.updatedAtMs);
}

class BrotherhoodDetailsCacheCompanion
    extends UpdateCompanion<BrotherhoodDetailsCacheData> {
  final Value<String> citySlug;
  final Value<int> year;
  final Value<String> brotherhoodSlug;
  final Value<String> payloadJson;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const BrotherhoodDetailsCacheCompanion({
    this.citySlug = const Value.absent(),
    this.year = const Value.absent(),
    this.brotherhoodSlug = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BrotherhoodDetailsCacheCompanion.insert({
    required String citySlug,
    required int year,
    required String brotherhoodSlug,
    required String payloadJson,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : citySlug = Value(citySlug),
       year = Value(year),
       brotherhoodSlug = Value(brotherhoodSlug),
       payloadJson = Value(payloadJson),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<BrotherhoodDetailsCacheData> custom({
    Expression<String>? citySlug,
    Expression<int>? year,
    Expression<String>? brotherhoodSlug,
    Expression<String>? payloadJson,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (citySlug != null) 'city_slug': citySlug,
      if (year != null) 'year': year,
      if (brotherhoodSlug != null) 'brotherhood_slug': brotherhoodSlug,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BrotherhoodDetailsCacheCompanion copyWith({
    Value<String>? citySlug,
    Value<int>? year,
    Value<String>? brotherhoodSlug,
    Value<String>? payloadJson,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return BrotherhoodDetailsCacheCompanion(
      citySlug: citySlug ?? this.citySlug,
      year: year ?? this.year,
      brotherhoodSlug: brotherhoodSlug ?? this.brotherhoodSlug,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (citySlug.present) {
      map['city_slug'] = Variable<String>(citySlug.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (brotherhoodSlug.present) {
      map['brotherhood_slug'] = Variable<String>(brotherhoodSlug.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BrotherhoodDetailsCacheCompanion(')
          ..write('citySlug: $citySlug, ')
          ..write('year: $year, ')
          ..write('brotherhoodSlug: $brotherhoodSlug, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BrotherhoodsCacheTable brotherhoodsCache =
      $BrotherhoodsCacheTable(this);
  late final $DaysCacheTable daysCache = $DaysCacheTable(this);
  late final $DayBrotherhoodsCacheTable dayBrotherhoodsCache =
      $DayBrotherhoodsCacheTable(this);
  late final $DayDetailsCacheTable dayDetailsCache = $DayDetailsCacheTable(
    this,
  );
  late final $BrotherhoodDetailsCacheTable brotherhoodDetailsCache =
      $BrotherhoodDetailsCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    brotherhoodsCache,
    daysCache,
    dayBrotherhoodsCache,
    dayDetailsCache,
    brotherhoodDetailsCache,
  ];
}

typedef $$BrotherhoodsCacheTableCreateCompanionBuilder =
    BrotherhoodsCacheCompanion Function({
      required String citySlug,
      required int year,
      required String slug,
      required String name,
      Value<String?> fullName,
      Value<String?> colorHex,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$BrotherhoodsCacheTableUpdateCompanionBuilder =
    BrotherhoodsCacheCompanion Function({
      Value<String> citySlug,
      Value<int> year,
      Value<String> slug,
      Value<String> name,
      Value<String?> fullName,
      Value<String?> colorHex,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$BrotherhoodsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $BrotherhoodsCacheTable> {
  $$BrotherhoodsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BrotherhoodsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $BrotherhoodsCacheTable> {
  $$BrotherhoodsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BrotherhoodsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $BrotherhoodsCacheTable> {
  $$BrotherhoodsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$BrotherhoodsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BrotherhoodsCacheTable,
          BrotherhoodsCacheData,
          $$BrotherhoodsCacheTableFilterComposer,
          $$BrotherhoodsCacheTableOrderingComposer,
          $$BrotherhoodsCacheTableAnnotationComposer,
          $$BrotherhoodsCacheTableCreateCompanionBuilder,
          $$BrotherhoodsCacheTableUpdateCompanionBuilder,
          (
            BrotherhoodsCacheData,
            BaseReferences<
              _$AppDatabase,
              $BrotherhoodsCacheTable,
              BrotherhoodsCacheData
            >,
          ),
          BrotherhoodsCacheData,
          PrefetchHooks Function()
        > {
  $$BrotherhoodsCacheTableTableManager(
    _$AppDatabase db,
    $BrotherhoodsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BrotherhoodsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BrotherhoodsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BrotherhoodsCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> citySlug = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BrotherhoodsCacheCompanion(
                citySlug: citySlug,
                year: year,
                slug: slug,
                name: name,
                fullName: fullName,
                colorHex: colorHex,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String citySlug,
                required int year,
                required String slug,
                required String name,
                Value<String?> fullName = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => BrotherhoodsCacheCompanion.insert(
                citySlug: citySlug,
                year: year,
                slug: slug,
                name: name,
                fullName: fullName,
                colorHex: colorHex,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BrotherhoodsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BrotherhoodsCacheTable,
      BrotherhoodsCacheData,
      $$BrotherhoodsCacheTableFilterComposer,
      $$BrotherhoodsCacheTableOrderingComposer,
      $$BrotherhoodsCacheTableAnnotationComposer,
      $$BrotherhoodsCacheTableCreateCompanionBuilder,
      $$BrotherhoodsCacheTableUpdateCompanionBuilder,
      (
        BrotherhoodsCacheData,
        BaseReferences<
          _$AppDatabase,
          $BrotherhoodsCacheTable,
          BrotherhoodsCacheData
        >,
      ),
      BrotherhoodsCacheData,
      PrefetchHooks Function()
    >;
typedef $$DaysCacheTableCreateCompanionBuilder =
    DaysCacheCompanion Function({
      required String citySlug,
      required int year,
      required String mode,
      required String slug,
      Value<String?> name,
      Value<String?> startsAt,
      Value<int> processionEventsCount,
      Value<int?> sortOrder,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$DaysCacheTableUpdateCompanionBuilder =
    DaysCacheCompanion Function({
      Value<String> citySlug,
      Value<int> year,
      Value<String> mode,
      Value<String> slug,
      Value<String?> name,
      Value<String?> startsAt,
      Value<int> processionEventsCount,
      Value<int?> sortOrder,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$DaysCacheTableFilterComposer
    extends Composer<_$AppDatabase, $DaysCacheTable> {
  $$DaysCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get processionEventsCount => $composableBuilder(
    column: $table.processionEventsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DaysCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $DaysCacheTable> {
  $$DaysCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get processionEventsCount => $composableBuilder(
    column: $table.processionEventsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DaysCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $DaysCacheTable> {
  $$DaysCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<int> get processionEventsCount => $composableBuilder(
    column: $table.processionEventsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$DaysCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DaysCacheTable,
          DaysCacheData,
          $$DaysCacheTableFilterComposer,
          $$DaysCacheTableOrderingComposer,
          $$DaysCacheTableAnnotationComposer,
          $$DaysCacheTableCreateCompanionBuilder,
          $$DaysCacheTableUpdateCompanionBuilder,
          (
            DaysCacheData,
            BaseReferences<_$AppDatabase, $DaysCacheTable, DaysCacheData>,
          ),
          DaysCacheData,
          PrefetchHooks Function()
        > {
  $$DaysCacheTableTableManager(_$AppDatabase db, $DaysCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DaysCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DaysCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DaysCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> citySlug = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> startsAt = const Value.absent(),
                Value<int> processionEventsCount = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DaysCacheCompanion(
                citySlug: citySlug,
                year: year,
                mode: mode,
                slug: slug,
                name: name,
                startsAt: startsAt,
                processionEventsCount: processionEventsCount,
                sortOrder: sortOrder,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String citySlug,
                required int year,
                required String mode,
                required String slug,
                Value<String?> name = const Value.absent(),
                Value<String?> startsAt = const Value.absent(),
                Value<int> processionEventsCount = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => DaysCacheCompanion.insert(
                citySlug: citySlug,
                year: year,
                mode: mode,
                slug: slug,
                name: name,
                startsAt: startsAt,
                processionEventsCount: processionEventsCount,
                sortOrder: sortOrder,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DaysCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DaysCacheTable,
      DaysCacheData,
      $$DaysCacheTableFilterComposer,
      $$DaysCacheTableOrderingComposer,
      $$DaysCacheTableAnnotationComposer,
      $$DaysCacheTableCreateCompanionBuilder,
      $$DaysCacheTableUpdateCompanionBuilder,
      (
        DaysCacheData,
        BaseReferences<_$AppDatabase, $DaysCacheTable, DaysCacheData>,
      ),
      DaysCacheData,
      PrefetchHooks Function()
    >;
typedef $$DayBrotherhoodsCacheTableCreateCompanionBuilder =
    DayBrotherhoodsCacheCompanion Function({
      required String citySlug,
      required int year,
      required String mode,
      required String daySlug,
      required String brotherhoodSlug,
      required String brotherhoodName,
      Value<String?> brotherhoodColorHex,
      Value<String?> status,
      Value<int> position,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$DayBrotherhoodsCacheTableUpdateCompanionBuilder =
    DayBrotherhoodsCacheCompanion Function({
      Value<String> citySlug,
      Value<int> year,
      Value<String> mode,
      Value<String> daySlug,
      Value<String> brotherhoodSlug,
      Value<String> brotherhoodName,
      Value<String?> brotherhoodColorHex,
      Value<String?> status,
      Value<int> position,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$DayBrotherhoodsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $DayBrotherhoodsCacheTable> {
  $$DayBrotherhoodsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodSlug => $composableBuilder(
    column: $table.brotherhoodSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodName => $composableBuilder(
    column: $table.brotherhoodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodColorHex => $composableBuilder(
    column: $table.brotherhoodColorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayBrotherhoodsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $DayBrotherhoodsCacheTable> {
  $$DayBrotherhoodsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodSlug => $composableBuilder(
    column: $table.brotherhoodSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodName => $composableBuilder(
    column: $table.brotherhoodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodColorHex => $composableBuilder(
    column: $table.brotherhoodColorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayBrotherhoodsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayBrotherhoodsCacheTable> {
  $$DayBrotherhoodsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get daySlug =>
      $composableBuilder(column: $table.daySlug, builder: (column) => column);

  GeneratedColumn<String> get brotherhoodSlug => $composableBuilder(
    column: $table.brotherhoodSlug,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherhoodName => $composableBuilder(
    column: $table.brotherhoodName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brotherhoodColorHex => $composableBuilder(
    column: $table.brotherhoodColorHex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$DayBrotherhoodsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayBrotherhoodsCacheTable,
          DayBrotherhoodsCacheData,
          $$DayBrotherhoodsCacheTableFilterComposer,
          $$DayBrotherhoodsCacheTableOrderingComposer,
          $$DayBrotherhoodsCacheTableAnnotationComposer,
          $$DayBrotherhoodsCacheTableCreateCompanionBuilder,
          $$DayBrotherhoodsCacheTableUpdateCompanionBuilder,
          (
            DayBrotherhoodsCacheData,
            BaseReferences<
              _$AppDatabase,
              $DayBrotherhoodsCacheTable,
              DayBrotherhoodsCacheData
            >,
          ),
          DayBrotherhoodsCacheData,
          PrefetchHooks Function()
        > {
  $$DayBrotherhoodsCacheTableTableManager(
    _$AppDatabase db,
    $DayBrotherhoodsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayBrotherhoodsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayBrotherhoodsCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DayBrotherhoodsCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> citySlug = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> daySlug = const Value.absent(),
                Value<String> brotherhoodSlug = const Value.absent(),
                Value<String> brotherhoodName = const Value.absent(),
                Value<String?> brotherhoodColorHex = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayBrotherhoodsCacheCompanion(
                citySlug: citySlug,
                year: year,
                mode: mode,
                daySlug: daySlug,
                brotherhoodSlug: brotherhoodSlug,
                brotherhoodName: brotherhoodName,
                brotherhoodColorHex: brotherhoodColorHex,
                status: status,
                position: position,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String citySlug,
                required int year,
                required String mode,
                required String daySlug,
                required String brotherhoodSlug,
                required String brotherhoodName,
                Value<String?> brotherhoodColorHex = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> position = const Value.absent(),
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => DayBrotherhoodsCacheCompanion.insert(
                citySlug: citySlug,
                year: year,
                mode: mode,
                daySlug: daySlug,
                brotherhoodSlug: brotherhoodSlug,
                brotherhoodName: brotherhoodName,
                brotherhoodColorHex: brotherhoodColorHex,
                status: status,
                position: position,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayBrotherhoodsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayBrotherhoodsCacheTable,
      DayBrotherhoodsCacheData,
      $$DayBrotherhoodsCacheTableFilterComposer,
      $$DayBrotherhoodsCacheTableOrderingComposer,
      $$DayBrotherhoodsCacheTableAnnotationComposer,
      $$DayBrotherhoodsCacheTableCreateCompanionBuilder,
      $$DayBrotherhoodsCacheTableUpdateCompanionBuilder,
      (
        DayBrotherhoodsCacheData,
        BaseReferences<
          _$AppDatabase,
          $DayBrotherhoodsCacheTable,
          DayBrotherhoodsCacheData
        >,
      ),
      DayBrotherhoodsCacheData,
      PrefetchHooks Function()
    >;
typedef $$DayDetailsCacheTableCreateCompanionBuilder =
    DayDetailsCacheCompanion Function({
      required String citySlug,
      required int year,
      required String mode,
      required String daySlug,
      required String payloadJson,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$DayDetailsCacheTableUpdateCompanionBuilder =
    DayDetailsCacheCompanion Function({
      Value<String> citySlug,
      Value<int> year,
      Value<String> mode,
      Value<String> daySlug,
      Value<String> payloadJson,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$DayDetailsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $DayDetailsCacheTable> {
  $$DayDetailsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayDetailsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $DayDetailsCacheTable> {
  $$DayDetailsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daySlug => $composableBuilder(
    column: $table.daySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayDetailsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayDetailsCacheTable> {
  $$DayDetailsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get daySlug =>
      $composableBuilder(column: $table.daySlug, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$DayDetailsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayDetailsCacheTable,
          DayDetailsCacheData,
          $$DayDetailsCacheTableFilterComposer,
          $$DayDetailsCacheTableOrderingComposer,
          $$DayDetailsCacheTableAnnotationComposer,
          $$DayDetailsCacheTableCreateCompanionBuilder,
          $$DayDetailsCacheTableUpdateCompanionBuilder,
          (
            DayDetailsCacheData,
            BaseReferences<
              _$AppDatabase,
              $DayDetailsCacheTable,
              DayDetailsCacheData
            >,
          ),
          DayDetailsCacheData,
          PrefetchHooks Function()
        > {
  $$DayDetailsCacheTableTableManager(
    _$AppDatabase db,
    $DayDetailsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayDetailsCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayDetailsCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayDetailsCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> citySlug = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> daySlug = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayDetailsCacheCompanion(
                citySlug: citySlug,
                year: year,
                mode: mode,
                daySlug: daySlug,
                payloadJson: payloadJson,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String citySlug,
                required int year,
                required String mode,
                required String daySlug,
                required String payloadJson,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => DayDetailsCacheCompanion.insert(
                citySlug: citySlug,
                year: year,
                mode: mode,
                daySlug: daySlug,
                payloadJson: payloadJson,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayDetailsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayDetailsCacheTable,
      DayDetailsCacheData,
      $$DayDetailsCacheTableFilterComposer,
      $$DayDetailsCacheTableOrderingComposer,
      $$DayDetailsCacheTableAnnotationComposer,
      $$DayDetailsCacheTableCreateCompanionBuilder,
      $$DayDetailsCacheTableUpdateCompanionBuilder,
      (
        DayDetailsCacheData,
        BaseReferences<
          _$AppDatabase,
          $DayDetailsCacheTable,
          DayDetailsCacheData
        >,
      ),
      DayDetailsCacheData,
      PrefetchHooks Function()
    >;
typedef $$BrotherhoodDetailsCacheTableCreateCompanionBuilder =
    BrotherhoodDetailsCacheCompanion Function({
      required String citySlug,
      required int year,
      required String brotherhoodSlug,
      required String payloadJson,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$BrotherhoodDetailsCacheTableUpdateCompanionBuilder =
    BrotherhoodDetailsCacheCompanion Function({
      Value<String> citySlug,
      Value<int> year,
      Value<String> brotherhoodSlug,
      Value<String> payloadJson,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$BrotherhoodDetailsCacheTableFilterComposer
    extends Composer<_$AppDatabase, $BrotherhoodDetailsCacheTable> {
  $$BrotherhoodDetailsCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brotherhoodSlug => $composableBuilder(
    column: $table.brotherhoodSlug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BrotherhoodDetailsCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $BrotherhoodDetailsCacheTable> {
  $$BrotherhoodDetailsCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get citySlug => $composableBuilder(
    column: $table.citySlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brotherhoodSlug => $composableBuilder(
    column: $table.brotherhoodSlug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BrotherhoodDetailsCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $BrotherhoodDetailsCacheTable> {
  $$BrotherhoodDetailsCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get citySlug =>
      $composableBuilder(column: $table.citySlug, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get brotherhoodSlug => $composableBuilder(
    column: $table.brotherhoodSlug,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$BrotherhoodDetailsCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BrotherhoodDetailsCacheTable,
          BrotherhoodDetailsCacheData,
          $$BrotherhoodDetailsCacheTableFilterComposer,
          $$BrotherhoodDetailsCacheTableOrderingComposer,
          $$BrotherhoodDetailsCacheTableAnnotationComposer,
          $$BrotherhoodDetailsCacheTableCreateCompanionBuilder,
          $$BrotherhoodDetailsCacheTableUpdateCompanionBuilder,
          (
            BrotherhoodDetailsCacheData,
            BaseReferences<
              _$AppDatabase,
              $BrotherhoodDetailsCacheTable,
              BrotherhoodDetailsCacheData
            >,
          ),
          BrotherhoodDetailsCacheData,
          PrefetchHooks Function()
        > {
  $$BrotherhoodDetailsCacheTableTableManager(
    _$AppDatabase db,
    $BrotherhoodDetailsCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BrotherhoodDetailsCacheTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BrotherhoodDetailsCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BrotherhoodDetailsCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> citySlug = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<String> brotherhoodSlug = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BrotherhoodDetailsCacheCompanion(
                citySlug: citySlug,
                year: year,
                brotherhoodSlug: brotherhoodSlug,
                payloadJson: payloadJson,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String citySlug,
                required int year,
                required String brotherhoodSlug,
                required String payloadJson,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => BrotherhoodDetailsCacheCompanion.insert(
                citySlug: citySlug,
                year: year,
                brotherhoodSlug: brotherhoodSlug,
                payloadJson: payloadJson,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BrotherhoodDetailsCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BrotherhoodDetailsCacheTable,
      BrotherhoodDetailsCacheData,
      $$BrotherhoodDetailsCacheTableFilterComposer,
      $$BrotherhoodDetailsCacheTableOrderingComposer,
      $$BrotherhoodDetailsCacheTableAnnotationComposer,
      $$BrotherhoodDetailsCacheTableCreateCompanionBuilder,
      $$BrotherhoodDetailsCacheTableUpdateCompanionBuilder,
      (
        BrotherhoodDetailsCacheData,
        BaseReferences<
          _$AppDatabase,
          $BrotherhoodDetailsCacheTable,
          BrotherhoodDetailsCacheData
        >,
      ),
      BrotherhoodDetailsCacheData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BrotherhoodsCacheTableTableManager get brotherhoodsCache =>
      $$BrotherhoodsCacheTableTableManager(_db, _db.brotherhoodsCache);
  $$DaysCacheTableTableManager get daysCache =>
      $$DaysCacheTableTableManager(_db, _db.daysCache);
  $$DayBrotherhoodsCacheTableTableManager get dayBrotherhoodsCache =>
      $$DayBrotherhoodsCacheTableTableManager(_db, _db.dayBrotherhoodsCache);
  $$DayDetailsCacheTableTableManager get dayDetailsCache =>
      $$DayDetailsCacheTableTableManager(_db, _db.dayDetailsCache);
  $$BrotherhoodDetailsCacheTableTableManager get brotherhoodDetailsCache =>
      $$BrotherhoodDetailsCacheTableTableManager(
        _db,
        _db.brotherhoodDetailsCache,
      );
}
