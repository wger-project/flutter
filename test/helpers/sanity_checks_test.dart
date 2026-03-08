/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2025 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wger/helpers/sanity_checks.dart';
import 'dart:convert';

void main() {
  group('checkServerPaginationUrls', () {
    const testToken = 'test-token-123';
    const testBaseUrl = 'https://wger.example.com';

    test('returns valid when pagination URL matches base URL', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'count': 100,
            'next': 'https://wger.example.com/api/v2/exercise/?limit=1&offset=1',
            'previous': null,
            'results': [],
          }),
          200,
        );
      });

      final result = await checkServerPaginationUrls(
        baseUrl: testBaseUrl,
        token: testToken,
        client: client,
      );

      expect(result.isValid, isTrue);
    });

    test('detects host mismatch (localhost issue)', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'count': 100,
            'next': 'http://localhost:8000/api/v2/exercise/?limit=1&offset=1',
            'previous': null,
            'results': [],
          }),
          200,
        );
      });

      final result = await checkServerPaginationUrls(
        baseUrl: testBaseUrl,
        token: testToken,
        client: client,
      );

      expect(result.isValid, isFalse);
    });

    test('detects protocol mismatch (https vs http)', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'count': 100,
            'next': 'http://wger.example.com/api/v2/exercise/?limit=1&offset=1',
            'previous': null,
            'results': [],
          }),
          200,
        );
      });

      final result = await checkServerPaginationUrls(
        baseUrl: testBaseUrl,
        token: testToken,
        client: client,
      );

      expect(result.isValid, isFalse);
    });

    test('returns valid when next URL is null (no pagination)', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'count': 1,
            'next': null,
            'previous': null,
            'results': [],
          }),
          200,
        );
      });

      final result = await checkServerPaginationUrls(
        baseUrl: testBaseUrl,
        token: testToken,
        client: client,
      );

      expect(result.isValid, isTrue);
    });

    test('handles server error gracefully', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final result = await checkServerPaginationUrls(
        baseUrl: testBaseUrl,
        token: testToken,
        client: client,
      );

      expect(result.isValid, isFalse);
    });

    test('handles network errors gracefully', () async {
      final client = MockClient((request) async {
        throw Exception('Network error');
      });

      final result = await checkServerPaginationUrls(
        baseUrl: testBaseUrl,
        token: testToken,
        client: client,
      );

      expect(result.isValid, isFalse);
    });

    test('includes correct headers in request', () async {
      String? authHeader;
      String? acceptHeader;

      final client = MockClient((request) async {
        authHeader = request.headers['Authorization'];
        acceptHeader = request.headers['Accept'];

        return http.Response(
          jsonEncode({'count': 0, 'next': null, 'results': []}),
          200,
        );
      });

      await checkServerPaginationUrls(
        baseUrl: testBaseUrl,
        token: testToken,
        client: client,
      );

      expect(authHeader, 'Token $testToken');
      expect(acceptHeader, 'application/json');
    });

    test('handles port numbers correctly in URL comparison', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'count': 100,
            'next': 'https://wger.example.com:8443/api/v2/exercise/?limit=1&offset=1',
            'previous': null,
            'results': [],
          }),
          200,
        );
      });

      final result = await checkServerPaginationUrls(
        baseUrl: 'https://wger.example.com:8443',
        token: testToken,
        client: client,
      );

      expect(result.isValid, isTrue);
    });
  });
}
