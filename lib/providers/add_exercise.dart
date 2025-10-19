import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise_submission.dart';
import 'package:wger/models/exercises/exercise_submission_images.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/variation.dart';

import 'base_provider.dart';

class AddExerciseProvider with ChangeNotifier {
  final WgerBaseProvider baseProvider;
  static final _logger = Logger('AddExerciseProvider');

  AddExerciseProvider(this.baseProvider);

  // Images and their metadata (license info, style)
  final List<ExerciseSubmissionImage> _exerciseImages = [];

  List<ExerciseSubmissionImage> get exerciseImages => [..._exerciseImages];

  String author = '';
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
  List<Equipment> _equipment = [];
  List<Muscle> _primaryMuscles = [];
  List<Muscle> _secondaryMuscles = [];

  static const _exerciseSubmissionUrlPath = 'exercise-submission';
  static const _imagesUrlPath = 'exerciseimage';
  static const _checkLanguageUrlPath = 'check-language';

  void clear() {
    _exerciseImages.clear();
    languageTranslation = null;
    category = null;
    exerciseNameEn = null;
    exerciseNameTrans = null;
    descriptionEn = null;
    descriptionTrans = null;
    alternateNamesEn = [];
    alternateNamesTrans = [];
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
  void addExerciseImages(List<ExerciseSubmissionImage> images) {
    _exerciseImages.addAll(images);
    notifyListeners();
  }

  void removeImage(String path) {
    final file = _exerciseImages.where((element) => element.imageFile.path == path).first;
    _exerciseImages.remove(file);
    notifyListeners();
  }

  /// Main method to submit exercise with images
  ///
  /// Returns the ID of the created exercise
  /// Throws exception if submission fails
  Future<int> postExerciseToServer() async {
    try {
      // 1. Create the exercise
      final exerciseId = await addExerciseSubmission();

      // 2. Upload images if any exist
      if (_exerciseImages.isNotEmpty) {
        await addImages(exerciseId);
      }

      // 3. Clear all data after successful upload
      clear();

      return exerciseId;
    } catch (e) {
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
  Future<void> addImages(int exerciseId) async {
    for (final image in _exerciseImages) {
      final request = http.MultipartRequest('POST', baseProvider.makeUrl(_imagesUrlPath));
      request.headers.addAll(baseProvider.getDefaultHeaders(includeAuth: true));

      request.files.add(await http.MultipartFile.fromPath('image', image.imageFile.path));
      request.fields['exercise'] = exerciseId.toString();
      request.fields['license'] = CC_BY_SA_4_ID.toString();
      request.fields['is_main'] = 'false';

      final details = image.toJson();
      if (details.isNotEmpty) {
        request.fields.addAll(details);
      }

      try {
        final streamedResponse = await request.send();

        if (streamedResponse.statusCode == 201 || streamedResponse.statusCode == 200) {
          _logger.fine('Image uploaded successfully');
        } else {
          final response = await http.Response.fromStream(streamedResponse);
          throw Exception('Upload failed: ${streamedResponse.statusCode}');
        }
      } catch (e) {
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

    return false;
  }
}
