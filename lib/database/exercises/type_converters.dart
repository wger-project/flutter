import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/variation.dart';

class MuscleConverter extends TypeConverter<Muscle, String> {
  const MuscleConverter();

  @override
  Muscle fromSql(String fromDb) {
    return Muscle.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(Muscle value) {
    return json.encode(value.toJson());
  }
}

class EquipmentConverter extends TypeConverter<Equipment, String> {
  const EquipmentConverter();

  @override
  Equipment fromSql(String fromDb) {
    return Equipment.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(Equipment value) {
    return json.encode(value.toJson());
  }
}

class ExerciseCategoryConverter extends TypeConverter<ExerciseCategory, String> {
  const ExerciseCategoryConverter();

  @override
  ExerciseCategory fromSql(String fromDb) {
    return ExerciseCategory.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(ExerciseCategory value) {
    return json.encode(value.toJson());
  }
}

class LanguageConverter extends TypeConverter<Language, String> {
  const LanguageConverter();

  @override
  Language fromSql(String fromDb) {
    return Language.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(Language value) {
    return json.encode(value.toJson());
  }
}

class VariationConverter extends TypeConverter<Variation, String> {
  const VariationConverter();

  @override
  Variation fromSql(String fromDb) {
    return Variation.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(Variation value) {
    return json.encode(value.toJson());
  }
}
