// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_database.dart';

// ignore_for_file: type=lint
class $ExerciseTableItemsTable extends ExerciseTableItems
    with TableInfo<$ExerciseTableItemsTable, ExerciseTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseTableItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _exercisebaseMeta =
      const VerificationMeta('exercisebase');
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseBase?, String>
      exercisebase = GeneratedColumn<String>('exercisebase', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<ExerciseBase?>(
              $ExerciseTableItemsTable.$converterexercisebasen);
  static const VerificationMeta _muscleMeta = const VerificationMeta('muscle');
  @override
  late final GeneratedColumnWithTypeConverter<Muscle?, String> muscle =
      GeneratedColumn<String>('muscle', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Muscle?>($ExerciseTableItemsTable.$convertermusclen);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseCategory?, String>
      category = GeneratedColumn<String>('category', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<ExerciseCategory?>(
              $ExerciseTableItemsTable.$convertercategoryn);
  static const VerificationMeta _variationMeta =
      const VerificationMeta('variation');
  @override
  late final GeneratedColumnWithTypeConverter<Variation?, String> variation =
      GeneratedColumn<String>('variation', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Variation?>(
              $ExerciseTableItemsTable.$convertervariationn);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumnWithTypeConverter<Language?, String> language =
      GeneratedColumn<String>('language', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Language?>(
              $ExerciseTableItemsTable.$converterlanguagen);
  static const VerificationMeta _equipmentMeta =
      const VerificationMeta('equipment');
  @override
  late final GeneratedColumnWithTypeConverter<Equipment?, String> equipment =
      GeneratedColumn<String>('equipment', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<Equipment?>(
              $ExerciseTableItemsTable.$converterequipmentn);
  static const VerificationMeta _expiresInMeta =
      const VerificationMeta('expiresIn');
  @override
  late final GeneratedColumn<DateTime> expiresIn = GeneratedColumn<DateTime>(
      'expires_in', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        exercisebase,
        muscle,
        category,
        variation,
        language,
        equipment,
        expiresIn
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_table_items';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    context.handle(_exercisebaseMeta, const VerificationResult.success());
    context.handle(_muscleMeta, const VerificationResult.success());
    context.handle(_categoryMeta, const VerificationResult.success());
    context.handle(_variationMeta, const VerificationResult.success());
    context.handle(_languageMeta, const VerificationResult.success());
    context.handle(_equipmentMeta, const VerificationResult.success());
    if (data.containsKey('expires_in')) {
      context.handle(_expiresInMeta,
          expiresIn.isAcceptableOrUnknown(data['expires_in']!, _expiresInMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      exercisebase: $ExerciseTableItemsTable.$converterexercisebasen.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}exercisebase'])),
      muscle: $ExerciseTableItemsTable.$convertermusclen.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}muscle'])),
      category: $ExerciseTableItemsTable.$convertercategoryn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}category'])),
      variation: $ExerciseTableItemsTable.$convertervariationn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}variation'])),
      language: $ExerciseTableItemsTable.$converterlanguagen.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}language'])),
      equipment: $ExerciseTableItemsTable.$converterequipmentn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}equipment'])),
      expiresIn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_in']),
    );
  }

  @override
  $ExerciseTableItemsTable createAlias(String alias) {
    return $ExerciseTableItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<ExerciseBase, String> $converterexercisebase =
      const ExerciseBaseConverter();
  static TypeConverter<ExerciseBase?, String?> $converterexercisebasen =
      NullAwareTypeConverter.wrap($converterexercisebase);
  static TypeConverter<Muscle, String> $convertermuscle =
      const MuscleConverter();
  static TypeConverter<Muscle?, String?> $convertermusclen =
      NullAwareTypeConverter.wrap($convertermuscle);
  static TypeConverter<ExerciseCategory, String> $convertercategory =
      const ExerciseCategoryConverter();
  static TypeConverter<ExerciseCategory?, String?> $convertercategoryn =
      NullAwareTypeConverter.wrap($convertercategory);
  static TypeConverter<Variation, String> $convertervariation =
      const VariationConverter();
  static TypeConverter<Variation?, String?> $convertervariationn =
      NullAwareTypeConverter.wrap($convertervariation);
  static TypeConverter<Language, String> $converterlanguage =
      const LanguageConverter();
  static TypeConverter<Language?, String?> $converterlanguagen =
      NullAwareTypeConverter.wrap($converterlanguage);
  static TypeConverter<Equipment, String> $converterequipment =
      const EquipmentConverter();
  static TypeConverter<Equipment?, String?> $converterequipmentn =
      NullAwareTypeConverter.wrap($converterequipment);
}

class ExerciseTable extends DataClass implements Insertable<ExerciseTable> {
  final int id;
  final ExerciseBase? exercisebase;
  final Muscle? muscle;
  final ExerciseCategory? category;
  final Variation? variation;
  final Language? language;
  final Equipment? equipment;
  final DateTime? expiresIn;
  const ExerciseTable(
      {required this.id,
      this.exercisebase,
      this.muscle,
      this.category,
      this.variation,
      this.language,
      this.equipment,
      this.expiresIn});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || exercisebase != null) {
      final converter = $ExerciseTableItemsTable.$converterexercisebasen;
      map['exercisebase'] = Variable<String>(converter.toSql(exercisebase));
    }
    if (!nullToAbsent || muscle != null) {
      final converter = $ExerciseTableItemsTable.$convertermusclen;
      map['muscle'] = Variable<String>(converter.toSql(muscle));
    }
    if (!nullToAbsent || category != null) {
      final converter = $ExerciseTableItemsTable.$convertercategoryn;
      map['category'] = Variable<String>(converter.toSql(category));
    }
    if (!nullToAbsent || variation != null) {
      final converter = $ExerciseTableItemsTable.$convertervariationn;
      map['variation'] = Variable<String>(converter.toSql(variation));
    }
    if (!nullToAbsent || language != null) {
      final converter = $ExerciseTableItemsTable.$converterlanguagen;
      map['language'] = Variable<String>(converter.toSql(language));
    }
    if (!nullToAbsent || equipment != null) {
      final converter = $ExerciseTableItemsTable.$converterequipmentn;
      map['equipment'] = Variable<String>(converter.toSql(equipment));
    }
    if (!nullToAbsent || expiresIn != null) {
      map['expires_in'] = Variable<DateTime>(expiresIn);
    }
    return map;
  }

  ExerciseTableItemsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseTableItemsCompanion(
      id: Value(id),
      exercisebase: exercisebase == null && nullToAbsent
          ? const Value.absent()
          : Value(exercisebase),
      muscle:
          muscle == null && nullToAbsent ? const Value.absent() : Value(muscle),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      variation: variation == null && nullToAbsent
          ? const Value.absent()
          : Value(variation),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
      expiresIn: expiresIn == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresIn),
    );
  }

  factory ExerciseTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseTable(
      id: serializer.fromJson<int>(json['id']),
      exercisebase: serializer.fromJson<ExerciseBase?>(json['exercisebase']),
      muscle: serializer.fromJson<Muscle?>(json['muscle']),
      category: serializer.fromJson<ExerciseCategory?>(json['category']),
      variation: serializer.fromJson<Variation?>(json['variation']),
      language: serializer.fromJson<Language?>(json['language']),
      equipment: serializer.fromJson<Equipment?>(json['equipment']),
      expiresIn: serializer.fromJson<DateTime?>(json['expiresIn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exercisebase': serializer.toJson<ExerciseBase?>(exercisebase),
      'muscle': serializer.toJson<Muscle?>(muscle),
      'category': serializer.toJson<ExerciseCategory?>(category),
      'variation': serializer.toJson<Variation?>(variation),
      'language': serializer.toJson<Language?>(language),
      'equipment': serializer.toJson<Equipment?>(equipment),
      'expiresIn': serializer.toJson<DateTime?>(expiresIn),
    };
  }

  ExerciseTable copyWith(
          {int? id,
          Value<ExerciseBase?> exercisebase = const Value.absent(),
          Value<Muscle?> muscle = const Value.absent(),
          Value<ExerciseCategory?> category = const Value.absent(),
          Value<Variation?> variation = const Value.absent(),
          Value<Language?> language = const Value.absent(),
          Value<Equipment?> equipment = const Value.absent(),
          Value<DateTime?> expiresIn = const Value.absent()}) =>
      ExerciseTable(
        id: id ?? this.id,
        exercisebase:
            exercisebase.present ? exercisebase.value : this.exercisebase,
        muscle: muscle.present ? muscle.value : this.muscle,
        category: category.present ? category.value : this.category,
        variation: variation.present ? variation.value : this.variation,
        language: language.present ? language.value : this.language,
        equipment: equipment.present ? equipment.value : this.equipment,
        expiresIn: expiresIn.present ? expiresIn.value : this.expiresIn,
      );
  @override
  String toString() {
    return (StringBuffer('ExerciseTable(')
          ..write('id: $id, ')
          ..write('exercisebase: $exercisebase, ')
          ..write('muscle: $muscle, ')
          ..write('category: $category, ')
          ..write('variation: $variation, ')
          ..write('language: $language, ')
          ..write('equipment: $equipment, ')
          ..write('expiresIn: $expiresIn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, exercisebase, muscle, category, variation,
      language, equipment, expiresIn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseTable &&
          other.id == this.id &&
          other.exercisebase == this.exercisebase &&
          other.muscle == this.muscle &&
          other.category == this.category &&
          other.variation == this.variation &&
          other.language == this.language &&
          other.equipment == this.equipment &&
          other.expiresIn == this.expiresIn);
}

class ExerciseTableItemsCompanion extends UpdateCompanion<ExerciseTable> {
  final Value<int> id;
  final Value<ExerciseBase?> exercisebase;
  final Value<Muscle?> muscle;
  final Value<ExerciseCategory?> category;
  final Value<Variation?> variation;
  final Value<Language?> language;
  final Value<Equipment?> equipment;
  final Value<DateTime?> expiresIn;
  const ExerciseTableItemsCompanion({
    this.id = const Value.absent(),
    this.exercisebase = const Value.absent(),
    this.muscle = const Value.absent(),
    this.category = const Value.absent(),
    this.variation = const Value.absent(),
    this.language = const Value.absent(),
    this.equipment = const Value.absent(),
    this.expiresIn = const Value.absent(),
  });
  ExerciseTableItemsCompanion.insert({
    this.id = const Value.absent(),
    this.exercisebase = const Value.absent(),
    this.muscle = const Value.absent(),
    this.category = const Value.absent(),
    this.variation = const Value.absent(),
    this.language = const Value.absent(),
    this.equipment = const Value.absent(),
    this.expiresIn = const Value.absent(),
  });
  static Insertable<ExerciseTable> custom({
    Expression<int>? id,
    Expression<String>? exercisebase,
    Expression<String>? muscle,
    Expression<String>? category,
    Expression<String>? variation,
    Expression<String>? language,
    Expression<String>? equipment,
    Expression<DateTime>? expiresIn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exercisebase != null) 'exercisebase': exercisebase,
      if (muscle != null) 'muscle': muscle,
      if (category != null) 'category': category,
      if (variation != null) 'variation': variation,
      if (language != null) 'language': language,
      if (equipment != null) 'equipment': equipment,
      if (expiresIn != null) 'expires_in': expiresIn,
    });
  }

  ExerciseTableItemsCompanion copyWith(
      {Value<int>? id,
      Value<ExerciseBase?>? exercisebase,
      Value<Muscle?>? muscle,
      Value<ExerciseCategory?>? category,
      Value<Variation?>? variation,
      Value<Language?>? language,
      Value<Equipment?>? equipment,
      Value<DateTime?>? expiresIn}) {
    return ExerciseTableItemsCompanion(
      id: id ?? this.id,
      exercisebase: exercisebase ?? this.exercisebase,
      muscle: muscle ?? this.muscle,
      category: category ?? this.category,
      variation: variation ?? this.variation,
      language: language ?? this.language,
      equipment: equipment ?? this.equipment,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exercisebase.present) {
      final converter = $ExerciseTableItemsTable.$converterexercisebasen;

      map['exercisebase'] =
          Variable<String>(converter.toSql(exercisebase.value));
    }
    if (muscle.present) {
      final converter = $ExerciseTableItemsTable.$convertermusclen;

      map['muscle'] = Variable<String>(converter.toSql(muscle.value));
    }
    if (category.present) {
      final converter = $ExerciseTableItemsTable.$convertercategoryn;

      map['category'] = Variable<String>(converter.toSql(category.value));
    }
    if (variation.present) {
      final converter = $ExerciseTableItemsTable.$convertervariationn;

      map['variation'] = Variable<String>(converter.toSql(variation.value));
    }
    if (language.present) {
      final converter = $ExerciseTableItemsTable.$converterlanguagen;

      map['language'] = Variable<String>(converter.toSql(language.value));
    }
    if (equipment.present) {
      final converter = $ExerciseTableItemsTable.$converterequipmentn;

      map['equipment'] = Variable<String>(converter.toSql(equipment.value));
    }
    if (expiresIn.present) {
      map['expires_in'] = Variable<DateTime>(expiresIn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseTableItemsCompanion(')
          ..write('id: $id, ')
          ..write('exercisebase: $exercisebase, ')
          ..write('muscle: $muscle, ')
          ..write('category: $category, ')
          ..write('variation: $variation, ')
          ..write('language: $language, ')
          ..write('equipment: $equipment, ')
          ..write('expiresIn: $expiresIn')
          ..write(')'))
        .toString();
  }
}

abstract class _$ExerciseDatabase extends GeneratedDatabase {
  _$ExerciseDatabase(QueryExecutor e) : super(e);
  late final $ExerciseTableItemsTable exerciseTableItems =
      $ExerciseTableItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [exerciseTableItems];
}
