import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/alias.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/exercises/variation.dart';

import 'base_provider.dart';

class AddExerciseProvider with ChangeNotifier {
  final WgerBaseProvider baseProvider;

  AddExerciseProvider(this.baseProvider);

  List<File> get exerciseImages => [..._exerciseImages];
  List<File> _exerciseImages = [];
  String? _nameEn;
  String? _nameTranslation;
  String? _descriptionEn;
  String? _descriptionTranslation;
  int? _variationId;
  int? _newVariationForExercise;
  Language? language;
  List<String> _alternativeNamesEn = [];
  List<String> _alternativeNamesTranslation = [];
  ExerciseCategory? category;
  List<Exercise> _variations = [];
  List<Equipment> _equipment = [];
  List<Muscle> _primaryMuscles = [];
  List<Muscle> _secondaryMuscles = [];

  static const _exerciseBaseUrlPath = 'exercise-base';
  static const _imagesUrlPath = 'exerciseimage';
  static const _exerciseTranslationUrlPath = 'exercise-translation';
  static const _exerciseAliasPath = 'exercisealias';
  static const _exerciseVariationPath = 'variation';

  void clear() {
    _exerciseImages = [];
    language = null;
    category = null;
    _nameEn = null;
    _nameTranslation = null;
    _descriptionEn = null;
    _descriptionTranslation = null;
    _alternativeNamesEn = [];
    _alternativeNamesTranslation = [];
    _variations = [];
    _equipment = [];
    _primaryMuscles = [];
    _secondaryMuscles = [];
  }

  set exerciseNameEn(String name) => _nameEn = name;

  set exerciseNameTrans(String name) => _nameTranslation = name;

  set descriptionEn(String description) => _descriptionEn = description;

  set descriptionTrans(String description) => _descriptionTranslation = description;

  set alternateNamesEn(List<String> names) => _alternativeNamesEn = names;

  set alternateNamesTrans(List<String> names) => _alternativeNamesTranslation = names;

  set equipment(List<Equipment> equipment) => _equipment = equipment;

  List<Equipment> get equipment => [..._equipment];

  bool get newVariation => _newVariationForExercise != null;

  int? get newVariationForExercise => _newVariationForExercise;

  set newVariationForExercise(int? value) {
    _newVariationForExercise = value;
    _variationId = null;
    notifyListeners();
  }

  int? get variationId => _variationId;

  set variationId(int? variation) {
    _variationId = variation;
    _newVariationForExercise = null;
    notifyListeners();
  }

  Exercise get exercise {
    return Exercise(
      category: category,
      equipment: _equipment,
      muscles: _primaryMuscles,
      musclesSecondary: _secondaryMuscles,
      variationId: _variationId,
    );
  }

  Translation get translationEn {
    return Translation(
      name: _nameEn!,
      description: _descriptionEn!,
      language: const Language(id: 2, fullName: 'English', shortName: 'en'),
    );
  }

  Translation get translation {
    return Translation(
      name: _nameTranslation!,
      description: _descriptionTranslation!,
      language: language,
    );
  }

  Variation get variation {
    return Variation(id: _variationId!);
  }

  List<Muscle> get primaryMuscles => [..._primaryMuscles];

  set primaryMuscles(List<Muscle> muscles) {
    _primaryMuscles = muscles;
    notifyListeners();
  }

  List<Muscle> get secondaryMuscles => [..._secondaryMuscles];

  set secondaryMuscles(List<Muscle> muscles) {
    _secondaryMuscles = muscles;
    notifyListeners();
  }

  void addExerciseImages(List<File> exercises) {
    _exerciseImages.addAll(exercises);
    notifyListeners();
  }

  void removeExercise(String path) {
    final file = _exerciseImages.where((element) => element.path == path).first;
    _exerciseImages.remove(file);
    notifyListeners();
  }

  //Just to Debug Provider
  void printValues() {
    log('Collected exercise data');
    log('------------------------');

    log('Base data...');
    log('Target area : $category');
    log('Primary muscles: $_primaryMuscles');
    log('Secondary muscles: $_secondaryMuscles');
    log('Equipment: $_equipment');
    log('Variations: $_variations');

    log('');
    log('Language specific...');
    log('Language: ${language?.shortName}');
    log('Name: en/$_nameEn translation/$_nameTranslation');
    log('Description: en/$_descriptionEn translation/$_descriptionTranslation');
    log('Alternate names: en/$_alternativeNamesEn translation/$_alternativeNamesTranslation');
  }

  Future<int> addExercise() async {
    printValues();

    // Create the variations if needed
    if (newVariation) {
      await addVariation();
    }

    // Create the exercise
    final exercise = await addExerciseBase();

    // Create the base description in English
    Translation exerciseTranslationEn = translationEn;
    exerciseTranslationEn.exercise = exercise;
    exerciseTranslationEn = await addExerciseTranslation(exerciseTranslationEn);
    for (final alias in _alternativeNamesEn) {
      if (alias.isNotEmpty) {
        exerciseTranslationEn.aliases.add(await addExerciseAlias(alias, exerciseTranslationEn.id!));
      }
    }

    // Create the translations
    if (language != null) {
      Translation exerciseTranslationLang = translation;
      exerciseTranslationLang.exercise = exercise;
      exerciseTranslationLang = await addExerciseTranslation(exerciseTranslationLang);
      for (final alias in _alternativeNamesTranslation) {
        if (alias.isNotEmpty) {
          exerciseTranslationLang.aliases.add(
            await addExerciseAlias(alias, exerciseTranslationLang.id!),
          );
        }
      }
      await addExerciseTranslation(exerciseTranslationLang);
    }

    // Create the images
    await addImages(exercise);

    // Clear everything
    clear();

    // Return exercise ID
    return exercise.id!;
  }

  Future<Exercise> addExerciseBase() async {
    final Uri postUri = baseProvider.makeUrl(_exerciseBaseUrlPath);

    final Map<String, dynamic> newBaseMap = await baseProvider.post(exercise.toJson(), postUri);
    final Exercise newExerciseBase = Exercise.fromJson(newBaseMap);
    notifyListeners();

    return newExerciseBase;
  }

  Future<Variation> addVariation() async {
    final Uri postUri = baseProvider.makeUrl(_exerciseVariationPath);

    // We send an empty dictionary since at the moment the variations only have an ID
    final Map<String, dynamic> variationMap = await baseProvider.post({}, postUri);
    final Variation newVariation = Variation.fromJson(variationMap);
    _variationId = newVariation.id;
    notifyListeners();
    return newVariation;
  }

  Future<void> addImages(Exercise base) async {
    for (final image in _exerciseImages) {
      final request = http.MultipartRequest('POST', baseProvider.makeUrl(_imagesUrlPath));
      request.headers.addAll(baseProvider.getDefaultHeaders(includeAuth: true));

      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.fields['exercise_base'] = base.id!.toString();
      request.fields['style'] = EXERCISE_IMAGE_ART_STYLE.PHOTO.index.toString();

      await request.send();
    }

    notifyListeners();
  }

  Future<Translation> addExerciseTranslation(Translation exercise) async {
    final Uri postUri = baseProvider.makeUrl(_exerciseTranslationUrlPath);

    final Map<String, dynamic> newTranslation = await baseProvider.post(exercise.toJson(), postUri);
    final Translation newExercise = Translation.fromJson(newTranslation);
    notifyListeners();

    return newExercise;
  }

  Future<Alias> addExerciseAlias(String name, int exerciseId) async {
    final alias = Alias(exerciseId: exerciseId, alias: name);
    final Uri postUri = baseProvider.makeUrl(_exerciseAliasPath);

    final Alias newAlias = Alias.fromJson(await baseProvider.post(alias.toJson(), postUri));
    notifyListeners();

    return newAlias;
  }
}
