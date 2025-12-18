/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2025 wger Team
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

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

enum ErrorType {
  json,
  html,
  text,
}

const HTML_ERROR_KEY = 'html_error';

class WgerHttpException implements Exception {
  Map<String, dynamic> errors = {};

  /// The exception type. While the majority will be json, it is possible that
  /// the server will return HTML, e.g. if there has been an internal server error
  /// or similar.
  late ErrorType type;

  /// Custom http exception
  WgerHttpException(Response response) {
    type = ErrorType.json;
    final dynamic responseBody = response.body;

    final contentType = response.headers[HttpHeaders.contentTypeHeader];
    if (contentType != null && contentType.contains('text/html')) {
      type = ErrorType.html;
    }

    if (responseBody == null) {
      errors = {'unknown_error': 'An unknown error occurred, no further information available'};
    } else {
      try {
        if (type == ErrorType.json) {
          final response = json.decode(responseBody);
          errors = (response is Map ? response : {'unknown_error': response})
              .cast<String, dynamic>();
        } else if (type == ErrorType.html) {
          errors = {HTML_ERROR_KEY: responseBody.toString()};
        } else {
          errors = {'text_error': responseBody.toString()};
        }
      } catch (e) {
        errors = {'unknown_error': responseBody};
      }
    }
  }

  WgerHttpException.fromMap(Map<String, dynamic> map) : type = ErrorType.json {
    errors = map;
  }

  String get htmlError {
    if (type != ErrorType.html) {
      return '';
    }

    return errors[HTML_ERROR_KEY] ?? '';
  }

  @override
  String toString() {
    return 'WgerHttpException ($type): $errors';
  }
}
