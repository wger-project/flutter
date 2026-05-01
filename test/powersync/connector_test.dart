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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/powersync/api_client.dart';
import 'package:wger/powersync/connector.dart';

import 'connector_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late DjangoConnector connector;

  setUp(() {
    connector = DjangoConnector(baseUrl: 'http://example.invalid');
  });

  /// Builds a JWT-shaped string with the given payload (signature is a sham,
  /// we only ever decode the middle segment).
  String makeJwt(Map<String, dynamic> payload) {
    String enc(Map<String, dynamic> m) => base64Url
        .encode(utf8.encode(jsonEncode(m)))
        .replaceAll(
          '=',
          '',
        );
    return '${enc({'alg': 'HS256', 'typ': 'JWT'})}.${enc(payload)}.signature';
  }

  group('genericTransform', () {
    test('injects the row id and copies all fields', () {
      final out = connector.genericTransform(
        'manager_workoutsession',
        {'notes': 'leg day', 'impression': 1},
        '42',
      );
      expect(out, {'id': '42', 'notes': 'leg day', 'impression': 1});
    });

    test('strips the `_id` suffix from foreign-key column names', () {
      final out = connector.genericTransform(
        'manager_workoutsession',
        {'routine_id': 7, 'notes': 'x'},
        '1',
      );
      expect(out['routine'], 7);
      expect(out.containsKey('routine_id'), isFalse);
    });

    test('handles null opData (delete events)', () {
      final out = connector.genericTransform('manager_routine', null, '99');
      expect(out, {'id': '99'});
    });

    group('date-only field trimming', () {
      test('strips the time component on `manager_routine.start`/`end`', () {
        final out = connector.genericTransform(
          'manager_routine',
          {
            'name': 'Push pull',
            'start': '2024-11-01T00:00:00.000Z',
            'end': '2024-12-01T00:00:00.000Z',
            'created': '2024-10-30T10:15:00.000Z',
          },
          '5',
        );
        // Date-only columns get trimmed so Django's DateField accepts them.
        expect(out['start'], '2024-11-01');
        expect(out['end'], '2024-12-01');
        // Other ISO timestamps (DateTimeField on Django) stay intact.
        expect(out['created'], '2024-10-30T10:15:00.000Z');
      });

      test('strips the time component on `manager_workoutsession.date`', () {
        final out = connector.genericTransform(
          'manager_workoutsession',
          {
            'date': '2024-11-01T00:00:00.000Z',
            'notes': 'felt great',
            'impression': '1',
          },
          '12',
        );
        expect(out['date'], '2024-11-01');
        expect(out['notes'], 'felt great');
      });

      test('strips the time component on `nutrition_nutritionplan.start`/`end`', () {
        final out = connector.genericTransform(
          'nutrition_nutritionplan',
          {
            'description': 'Cut',
            'start': '2024-11-01T00:00:00.000Z',
            'end': '2024-12-01T00:00:00.000Z',
            'creation_date': '2024-10-30T10:15:00.000Z',
          },
          '8',
        );
        expect(out['start'], '2024-11-01');
        expect(out['end'], '2024-12-01');
        expect(out['creation_date'], '2024-10-30T10:15:00.000Z');
      });

      test('does not touch DateTimeField columns even on registered tables', () {
        // `manager_workoutlog.date` is a DateTimeField on Django (not a
        // DateField), and `manager_workoutlog` isn't in the date-only
        // registry — the timestamp must round-trip unchanged.
        final out = connector.genericTransform(
          'manager_workoutlog',
          {'date': '2024-11-01T17:30:00.000Z'},
          '1',
        );
        expect(out['date'], '2024-11-01T17:30:00.000Z');
      });

      test('strips the time component on `gallery_image.date`', () {
        final out = connector.genericTransform(
          'gallery_image',
          {
            'date': '2024-11-01T00:00:00.000Z',
            'description': 'leg day pump',
          },
          '3',
        );
        expect(out['date'], '2024-11-01');
        expect(out['description'], 'leg day pump');
      });

      test('passes nulls through (open-ended end date)', () {
        final out = connector.genericTransform(
          'nutrition_nutritionplan',
          {'start': '2024-11-01T00:00:00.000Z', 'end': null},
          '8',
        );
        expect(out['start'], '2024-11-01');
        expect(out['end'], isNull);
      });
    });
  });

  group('decodeJwtPayload', () {
    test('decodes the middle segment into a map', () {
      final jwt = makeJwt({'sub': '42', 'exp': 1700000000});

      final payload = DjangoConnector.decodeJwtPayload(jwt);

      expect(payload, {'sub': '42', 'exp': 1700000000});
    });

    test('returns null when the JWT does not have three segments', () {
      expect(DjangoConnector.decodeJwtPayload('only.two'), isNull);
      expect(DjangoConnector.decodeJwtPayload('one'), isNull);
      expect(DjangoConnector.decodeJwtPayload('a.b.c.d'), isNull);
    });

    test('returns null when the middle segment is not valid base64-url', () {
      expect(DjangoConnector.decodeJwtPayload('aaa.!!!.bbb'), isNull);
    });

    test('returns null when the decoded segment is not JSON', () {
      final notJson = base64Url.encode(utf8.encode('not json')).replaceAll('=', '');
      expect(DjangoConnector.decodeJwtPayload('a.$notJson.b'), isNull);
    });
  });

  group('jwtExp', () {
    test('returns a UTC DateTime built from unix seconds', () {
      // 2023-11-14T22:13:20Z is exactly 1700000000 seconds past the epoch.
      final result = DjangoConnector.jwtExp({'exp': 1700000000});

      expect(result, DateTime.utc(2023, 11, 14, 22, 13, 20));
      expect(result!.isUtc, isTrue);
    });

    test('accepts double-encoded exp values (some JWT libraries produce these)', () {
      final result = DjangoConnector.jwtExp({'exp': 1700000000.5});

      expect(result, DateTime.utc(2023, 11, 14, 22, 13, 20));
    });

    test('returns null when payload is null', () {
      expect(DjangoConnector.jwtExp(null), isNull);
    });

    test('returns null when exp is missing', () {
      expect(DjangoConnector.jwtExp({'sub': '42'}), isNull);
    });

    test('returns null when exp is not numeric', () {
      expect(DjangoConnector.jwtExp({'exp': 'soon'}), isNull);
    });
  });

  group('fetchCredentials', () {
    test('builds PowerSyncCredentials with userId from sub and expiresAt from exp', () async {
      final mockApi = MockApiClient();
      final connector = DjangoConnector(baseUrl: 'http://example.invalid', apiClient: mockApi);
      final jwt = makeJwt({'sub': 'user-42', 'exp': 1700000000});
      when(mockApi.getPowersyncToken()).thenAnswer(
        (_) async => {'token': jwt, 'powersync_url': 'https://ps.example.com'},
      );

      final creds = await connector.fetchCredentials();

      expect(creds, isNotNull);
      expect(creds!.endpoint, 'https://ps.example.com');
      expect(creds.token, jwt);
      expect(creds.userId, 'user-42');
      expect(creds.expiresAt, DateTime.utc(2023, 11, 14, 22, 13, 20));
    });

    test('coerces a numeric sub into a String (Django sends ints)', () async {
      final mockApi = MockApiClient();
      final connector = DjangoConnector(baseUrl: 'http://example.invalid', apiClient: mockApi);
      final jwt = makeJwt({'sub': 42, 'exp': 1700000000});
      when(mockApi.getPowersyncToken()).thenAnswer(
        (_) async => {'token': jwt, 'powersync_url': 'https://ps.example.com'},
      );

      final creds = await connector.fetchCredentials();

      expect(creds!.userId, '42');
    });

    test('still produces credentials when JWT is opaque (userId/expiresAt null)', () async {
      final mockApi = MockApiClient();
      final connector = DjangoConnector(baseUrl: 'http://example.invalid', apiClient: mockApi);
      when(mockApi.getPowersyncToken()).thenAnswer(
        (_) async => {'token': 'not.a.jwt', 'powersync_url': 'https://ps.example.com'},
      );

      final creds = await connector.fetchCredentials();

      expect(creds!.endpoint, 'https://ps.example.com');
      expect(creds.token, 'not.a.jwt');
      expect(creds.userId, isNull);
      expect(creds.expiresAt, isNull);
    });
  });
}
