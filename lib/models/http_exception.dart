/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:convert';

class WgerHttpException implements Exception {
  Map<String, dynamic>? errors;

  /// Custom http exception.
  /// Expects the response body of the REST call and will try to parse it to
  /// JSON. Will use the response as-is if it fails.
  WgerHttpException(dynamic responseBody) {
    if (responseBody == null) {
      errors = {'unknown_error': 'An unknown error occurred, no further information available'};
    } else {
      try {
        errors = json.decode(responseBody);
      } catch (e) {
        errors = responseBody;
      }
    }
    this.errors = errors;
  }

  @override
  String toString() {
    return errors!.values.toList().join(', ');
  }
}
