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

import 'dart:convert';

import 'package:logging/logging.dart';

final _logger = Logger('jwt');

/// Decodes the payload (middle segment) of a JWT.
///
/// Returns null when the input is not a three-segment token, when the middle
/// segment is not valid base64-url, or when the decoded bytes are not a JSON
/// object. The signature is not verified, so callers must treat the result
/// as untrusted data.
Map<String, dynamic>? decodeJwtPayload(String jwt) {
  try {
    final parts = jwt.split('.');
    if (parts.length != 3) {
      return null;
    }
    return json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))))
        as Map<String, dynamic>;
  } catch (e) {
    _logger.warning('Could not decode JWT payload', e);
    return null;
  }
}

/// Extracts the `exp` claim (unix seconds) as a UTC [DateTime].
///
/// Returns null when the payload is null, when `exp` is missing, or when it is
/// not numeric. Fractional seconds are truncated.
DateTime? jwtExp(Map<String, dynamic>? payload) {
  final exp = payload?['exp'];
  if (exp is! num) {
    return null;
  }
  return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
}
