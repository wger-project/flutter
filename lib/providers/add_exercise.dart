import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/exercise_submission.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/variation.dart';

import 'base_provider.dart';

class AddExerciseProvider with ChangeNotifier {
  final WgerBaseProvider baseProvider;

  AddExerciseProvider(this.baseProvider);

  List<File> get exerciseImages => [..._exerciseImages];
  List<File> _exerciseImages = [];
  String? exerciseNameEn;
  String? exerciseNameTrans;
  String? descriptionEn;
  String? descriptionTrans;
  int? _variationId;
  int? _variationConnectToExercise;
  Language? languageEn;
  Language? languageTranslation;
  List<String> alternateNamesEn = [];
  List<String> alternateNamesTrans = [];
  ExerciseCategory? category;
  List<Exercise> _variations = [];
  List<Equipment> _equipment = [];
  List<Muscle> _primaryMuscles = [];
  List<Muscle> _secondaryMuscles = [];

  static const _exerciseSubmissionUrlPath = 'exercise-submission';
  static const _imagesUrlPath = 'exerciseimage';
  static const _checkLanguageUrlPath = 'check-language';

  void clear() {
    _exerciseImages = [];
    languageTranslation = null;
    category = null;
    exerciseNameEn = null;
    exerciseNameTrans = null;
    descriptionEn = null;
    descriptionTrans = null;
    alternateNamesEn = [];
    alternateNamesTrans = [];
    _variations = [];
    _equipment = [];
    _primaryMuscles = [];
    _secondaryMuscles = [];
  }

  set equipment(List<Equipment> equipment) => _equipment = equipment;

  List<Equipment> get equipment => [..._equipment];

  bool get newVariation => _variationConnectToExercise != null;

  int? get variationConnectToExercise => _variationConnectToExercise;

  set variationConnectToExercise(int? value) {
    _variationConnectToExercise = value;
    _variationId = null;
    notifyListeners();
  }

  int? get variationId => _variationId;

  set variationId(int? variation) {
    _variationId = variation;
    _variationConnectToExercise = null;
    notifyListeners();
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

  ExerciseSubmissionApi get exerciseApiObject {
    return ExerciseSubmissionApi(
      author: '',
      variation: _variationId,
      variationConnectTo: _variationConnectToExercise,
      category: category!.id,
      muscles: _primaryMuscles.map((e) => e.id).toList(),
      musclesSecondary: _secondaryMuscles.map((e) => e.id).toList(),
      equipment: _equipment.map((e) => e.id).toList(),
      translations: [
        // Base language (English)
        ExerciseTranslationSubmissionApi(
          author: '',
          language: languageEn!.id,
          name: exerciseNameEn!,
          description: descriptionEn!,
          aliases: alternateNamesEn
              .where((element) => element.isNotEmpty)
              .map((e) => ExerciseAliasSubmissionApi(alias: e))
              .toList(),
        ),

        // Optional translation
        if (languageTranslation != null)
          ExerciseTranslationSubmissionApi(
            author: '',
            language: languageTranslation!.id,
            name: exerciseNameTrans!,
            description: descriptionTrans!,
            aliases: alternateNamesTrans
                .where((element) => element.isNotEmpty)
                .map((e) => ExerciseAliasSubmissionApi(alias: e))
                .toList(),
          ),
      ],
    );
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
    log('Language: ${languageTranslation?.shortName}');
    log('Name: en/$exerciseNameEn translation/$exerciseNameTrans');
    log('Description: en/$descriptionEn translation/$descriptionTrans');
    log('Alternate names: en/$alternateNamesEn translation/$alternateNamesTrans');
  }

  Future<int> addExercise() async {
    printValues();

    // Create the variations if needed
    // if (newVariation) {
    //   await addVariation();
    // }

    // Create the exercise
    final exerciseId = await addExerciseSubmission();

    // Clear everything
    clear();

    // Return exercise ID
    return exerciseId;
  }

  Future<int> addExerciseSubmission() async {
    final Map<String, dynamic> result = await baseProvider.post(
      exerciseApiObject.toJson(),
      baseProvider.makeUrl(_exerciseSubmissionUrlPath),
    );
    notifyListeners();

    return result['id'];
  }

  Future<void> addImages(int exerciseId) async {
    for (final image in _exerciseImages) {
      final request = http.MultipartRequest('POST', baseProvider.makeUrl(_imagesUrlPath));
      request.headers.addAll(baseProvider.getDefaultHeaders(includeAuth: true));

      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.fields['exercise'] = exerciseId.toString();
      request.fields['style'] = EXERCISE_IMAGE_ART_STYLE.PHOTO.index.toString();

      await request.send();
    }

    notifyListeners();
  }

  Future<bool> validateLanguage(String input, String languageCode) async {
    final Map<String, dynamic> result = await baseProvider.post({
      'input': input,
      'language_code': languageCode,
    }, baseProvider.makeUrl(_checkLanguageUrlPath));
    notifyListeners();
    print(result);

    return false;
  }

  /*
    Note: all this logic is not needed now since we are using the /exercise-submission
    endpoint, however, if we ever want to implement editing of exercises, we will
    need basically all of it again, so this is kept here for reference.




  Future<Variation> addVariation() async {
    final Uri postUri = baseProvider.makeUrl(_exerciseVariationPath);

    // We send an empty dictionary since at the moment the variations only have an ID
    final Map<String, dynamic> variationMap = await baseProvider.post({}, postUri);
    final Variation newVariation = Variation.fromJson(variationMap);
    _variationId = newVariation.id;
    notifyListeners();
    return newVariation;
  }

  Future<void> addImages(Exercise exercise) async {
    for (final image in _exerciseImages) {
      final request = http.MultipartRequest('POST', baseProvider.makeUrl(_imagesUrlPath));
      request.headers.addAll(baseProvider.getDefaultHeaders(includeAuth: true));

      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.fields['exercise'] = exercise.id!.toString();
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
    final alias = Alias(translationId: exerciseId, alias: name);
    final Uri postUri = baseProvider.makeUrl(_exerciseAliasPath);

    final Alias newAlias = Alias.fromJson(await baseProvider.post(alias.toJson(), postUri));
    notifyListeners();

    return newAlias;
  }

   */
}
