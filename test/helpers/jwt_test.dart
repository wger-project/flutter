/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/jwt.dart';

void main() {
  /// Builds a JWT-shaped string with the given payload (signature is a sham,
  /// we only ever decode the middle segment).
  String makeJwt(Map<String, dynamic> payload) {
    String enc(Map<String, dynamic> m) =>
        base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
    return '${enc({'alg': 'HS256', 'typ': 'JWT'})}.${enc(payload)}.signature';
  }

  group('decodeJwtPayload', () {
    test('decodes the middle segment into a map', () {
      final jwt = makeJwt({'sub': '42', 'exp': 1700000000});

      final payload = decodeJwtPayload(jwt);

      expect(payload, {'sub': '42', 'exp': 1700000000});
    });

    test('returns null when the JWT does not have three segments', () {
      expect(decodeJwtPayload('only.two'), isNull);
      expect(decodeJwtPayload('one'), isNull);
      expect(decodeJwtPayload('a.b.c.d'), isNull);
    });

    test('returns null when the middle segment is not valid base64-url', () {
      expect(decodeJwtPayload('aaa.!!!.bbb'), isNull);
    });

    test('returns null when the decoded segment is not JSON', () {
      final notJson = base64Url.encode(utf8.encode('not json')).replaceAll('=', '');
      expect(decodeJwtPayload('a.$notJson.b'), isNull);
    });
  });

  group('jwtExp', () {
    test('returns a UTC DateTime built from unix seconds', () {
      // 2023-11-14T22:13:20Z is exactly 1700000000 seconds past the epoch.
      final result = jwtExp({'exp': 1700000000});

      expect(result, DateTime.utc(2023, 11, 14, 22, 13, 20));
      expect(result!.isUtc, isTrue);
    });

    test('accepts double-encoded exp values (some JWT libraries produce these)', () {
      final result = jwtExp({'exp': 1700000000.5});

      expect(result, DateTime.utc(2023, 11, 14, 22, 13, 20));
    });

    test('returns null when payload is null', () {
      expect(jwtExp(null), isNull);
    });

    test('returns null when exp is missing', () {
      expect(jwtExp({'sub': '42'}), isNull);
    });

    test('returns null when exp is not numeric', () {
      expect(jwtExp({'exp': 'soon'}), isNull);
    });
  });
}
