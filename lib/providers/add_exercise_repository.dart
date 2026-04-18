/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/exercise_submission.dart';
import 'package:wger/models/exercises/exercise_submission_images.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/wger_base.dart';

final addExerciseRepositoryProvider = Provider<AddExerciseRepository>((ref) {
  final base = ref.read(wgerBaseProvider);
  return AddExerciseRepository(base);
});

/// HTTP-only data access for the exercise contribution flow.
class AddExerciseRepository {
  static const _exerciseSubmissionUrlPath = 'exercise-submission';
  static const _imagesUrlPath = 'exerciseimage';
  static const _checkLanguageUrlPath = 'check-language';

  final _logger = Logger('AddExerciseRepository');
  final WgerBaseProvider _base;

  AddExerciseRepository(this._base);

  /// Submits the exercise to the server and returns the created id.
  Future<int> submit(ExerciseSubmissionApi payload) async {
    final Map<String, dynamic> result = await _base.post(
      payload.toJson(),
      _base.makeUrl(_exerciseSubmissionUrlPath),
    );
    return result['id'];
  }

  /// Uploads a single exercise image with license metadata.
  Future<void> uploadImage({
    required int exerciseId,
    required ExerciseSubmissionImage image,
    required String author,
  }) async {
    final request = http.MultipartRequest('POST', _base.makeUrl(_imagesUrlPath))
      ..headers.addAll(_base.getDefaultHeaders(includeAuth: true))
      ..files.add(await http.MultipartFile.fromPath('image', image.imageFile.path))
      ..fields['exercise'] = exerciseId.toString()
      ..fields['is_main'] = 'false'
      ..fields['license'] = CC_BY_SA_4_ID.toString()
      ..fields['license_author'] = author;

    final details = image.toJson();
    if (details.isNotEmpty) {
      request.fields.addAll(details);
    }

    final streamedResponse = await request.send();
    if (streamedResponse.statusCode == 201 || streamedResponse.statusCode == 200) {
      _logger.fine('Image uploaded successfully');
    } else {
      throw Exception('Upload failed: ${streamedResponse.statusCode}');
    }
  }

  Future<bool> validateLanguage(String input, String languageCode) async {
    await _base.post({
      'input': input,
      'language_code': languageCode,
    }, _base.makeUrl(_checkLanguageUrlPath));
    return false;
  }
}
