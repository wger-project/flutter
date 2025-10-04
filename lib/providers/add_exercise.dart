import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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

  // Map storing image metadata (license info, style), keyed by file path
  final Map<String, Map<String, String>> _imageDetails = {};

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
    _imageDetails.clear(); // Also clear image metadata
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

  /// Add images with optional license metadata
  ///
  /// [images] - List of image files to add
  /// [title] - License title
  /// [author] - Author name
  /// [authorUrl] - Author's URL
  /// [sourceUrl] - Source/object URL
  /// [derivativeSourceUrl] - Derivative source URL
  /// [style] - Image style: 1=PHOTO, 2=3D, 3=LINE, 4=LOW-POLY, 5=OTHER
  void addExerciseImages(
    List<File> images, {
    String? title,
    String? author,
    String? authorUrl,
    String? sourceUrl,
    String? derivativeSourceUrl,
    String style = '1',
  }) {
    _exerciseImages.addAll(images);

    // Store metadata for each image
    for (final image in images) {
      final details = <String, String>{'style': style};

      // Only add non-empty fields
      if (title != null && title.isNotEmpty) {
        details['license_title'] = title;
      }
      if (author != null && author.isNotEmpty) {
        details['license_author'] = author;
      }
      if (authorUrl != null && authorUrl.isNotEmpty) {
        details['license_author_url'] = authorUrl;
      }
      if (sourceUrl != null && sourceUrl.isNotEmpty) {
        details['license_object_url'] = sourceUrl;
      }
      if (derivativeSourceUrl != null && derivativeSourceUrl.isNotEmpty) {
        details['license_derivative_source_url'] = derivativeSourceUrl;
      }

      _imageDetails[image.path] = details;
    }

    notifyListeners();
  }

  void removeExercise(String path) {
    final file = _exerciseImages.where((element) => element.path == path).first;
    _exerciseImages.remove(file);
    _imageDetails.remove(path); // Also remove associated metadata
    notifyListeners();
  }

  // Debug method to print all collected exercise data
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

    log('');
    log('Images: ${_exerciseImages.length} images with details');
  }

  /// Main method to submit exercise with images
  ///
  /// Returns the ID of the created exercise
  /// Throws exception if submission fails
  Future<int> addExercise() async {
    printValues();

    try {
      // 1. Create the exercise
      final exerciseId = await addExerciseSubmission();
      print('Exercise created with ID: $exerciseId');

      // 2. Upload images if any exist
      if (_exerciseImages.isNotEmpty) {
        print('Uploading ${_exerciseImages.length} images...');
        await addImages(exerciseId);
        print('Images uploaded successfully');
      } else {
        print('ℹ No images to upload');
      }

      // 3. Clear all data after successful upload
      clear();

      return exerciseId;
    } catch (e) {
      print('Error adding exercise: $e');
      // Don't clear on error so user can retry
      rethrow;
    }
  }

  Future<int> addExerciseSubmission() async {
    final Map<String, dynamic> result = await baseProvider.post(
      exerciseApiObject.toJson(),
      baseProvider.makeUrl(_exerciseSubmissionUrlPath),
    );
    notifyListeners();

    return result['id'];
  }

  /// Upload exercise images with license metadata
  ///
  /// For each image:
  /// - Sends multipart request with image file
  /// - Includes license fields from _imageDetails map
  /// - Validates server response contains all submitted fields
  Future<void> addImages(int exerciseId) async {
    print('Starting image upload for exercise ID: $exerciseId');
    print('Number of images to upload: ${_exerciseImages.length}');

    for (final image in _exerciseImages) {
      print('Processing image: ${image.path}');

      final request = http.MultipartRequest('POST', baseProvider.makeUrl(_imagesUrlPath));
      request.headers.addAll(baseProvider.getDefaultHeaders(includeAuth: true));

      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.fields['exercise'] = exerciseId.toString();
      request.fields['license'] = '1';
      request.fields['is_main'] = 'false';

      final details = _imageDetails[image.path];
      print('Image details to send: $details');

      if (details != null && details.isNotEmpty) {
        request.fields.addAll(details);
        print('Request fields: ${request.fields}');
      } else {
        request.fields['style'] = '1';
      }

      try {
        print('Sending request...');
        final streamedResponse = await request.send();
        print('Response status: ${streamedResponse.statusCode}');

        // Read response body to verify upload success
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201 || response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          log('Image uploaded successfully!');
          log('Response body: ${response.body}');

          // Debug: Print all fields from server response
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('SERVER RESPONSE:');
          print('ID: ${responseData['id']}');
          print('UUID: ${responseData['uuid']}');
          print('Image URL: ${responseData['image']}');
          print('Exercise: ${responseData['exercise']}');
          print('Style: ${responseData['style']}');
          print('License: ${responseData['license']}');
          print('License Title: ${responseData['license_title']}');
          print('License Author: ${responseData['license_author']}');
          print('License Author URL: ${responseData['license_author_url']}');
          print('License Object URL: ${responseData['license_object_url']}');
          print('License Derivative: ${responseData['license_derivative_source_url']}');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

          // Validate that license fields were saved correctly
          if (details != null) {
            bool allFieldsMatch = true;

            if (details.containsKey('license_title') &&
                responseData['license_title'] != details['license_title']) {
              print('WARNING: license_title mismatch!');
              print('Sent: ${details['license_title']}');
              print('Received: ${responseData['license_title']}');
              allFieldsMatch = false;
            }

            if (details.containsKey('license_author') &&
                responseData['license_author'] != details['license_author']) {
              print('WARNING: license_author mismatch!');
              allFieldsMatch = false;
            }

            if (details.containsKey('license_author_url') &&
                responseData['license_author_url'] != details['license_author_url']) {
              print('WARNING: license_author_url mismatch!');
              allFieldsMatch = false;
            }

            if (details.containsKey('license_object_url') &&
                responseData['license_object_url'] != details['license_object_url']) {
              print('WARNING: license_object_url mismatch!');
              allFieldsMatch = false;
            }

            if (details.containsKey('license_derivative_source_url') &&
                responseData['license_derivative_source_url'] !=
                    details['license_derivative_source_url']) {
              print('WARNING: license_derivative_source_url mismatch!');
              allFieldsMatch = false;
            }

            if (allFieldsMatch) {
              print('ALL LICENSE FIELDS SAVED CORRECTLY!');
            } else {
              print('SOME LICENSE FIELDS NOT SAVED CORRECTLY!');
            }
          }
        } else {
          log('Failed to upload image: ${response.statusCode}');
          log('Response body: ${response.body}');
          throw Exception('Upload failed: ${response.statusCode}');
        }
      } catch (e) {
        log('Error uploading image: $e');
        rethrow;
      }
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
