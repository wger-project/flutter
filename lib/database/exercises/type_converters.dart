import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wger/models/exercises/alias.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/exercises/variation.dart';
import 'package:wger/models/exercises/video.dart';

class ExerciseBaseConverter extends TypeConverter<Exercise, String> {
  const ExerciseBaseConverter();

  @override
  Exercise fromSql(String fromDb) {
    final Map<String, dynamic> baseData = json.decode(fromDb);

    final category = ExerciseCategory.fromJson(baseData['categories']);
    final musclesPrimary = baseData['muscless'].map((e) => Muscle.fromJson(e)).toList();
    final musclesSecondary = baseData['musclesSecondary'].map((e) => Muscle.fromJson(e)).toList();
    final equipment = baseData['equipments'].map((e) => Equipment.fromJson(e)).toList();
    final images = baseData['images'].map((e) => ExerciseImage.fromJson(e)).toList();
    final videos = baseData['videos'].map((e) => Video.fromJson(e)).toList();

    final List<Translation> translations = [];
    for (final exerciseData in baseData['translations']) {
      final translation = Translation(
        id: exerciseData['id'],
        name: exerciseData['name'],
        description: exerciseData['description'],
        exerciseId: baseData['id'],
      );
      translation.aliases = exerciseData['aliases'].map((e) => Alias.fromJson(e)).toList();
      translation.notes = exerciseData['notes'].map((e) => Comment.fromJson(e)).toList();
      translation.language = Language.fromJson(exerciseData['languageObj']);
      translations.add(translation);
    }

    final exerciseBase = Exercise(
      id: baseData['id'],
      uuid: baseData['uuid'],
      created: null,
      //creationDate: toDate(baseData['creation_date']),
      musclesSecondary: musclesSecondary.cast<Muscle>(),
      muscles: musclesPrimary.cast<Muscle>(),
      equipment: equipment.cast<Equipment>(),
      category: category,
      images: images.cast<ExerciseImage>(),
      translations: translations,
      videos: videos.cast<Video>(),
    );
    return exerciseBase;
  }

  @override
  String toSql(Exercise value) {
    return json.encode(value.toJson());
  }
}

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
