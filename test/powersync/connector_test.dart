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
import 'dart:io';

import 'package:drift/drift.dart' show GeneratedColumnWithTypeConverter;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:powersync/powersync.dart';
import 'package:wger/database/converters/date_only_text_converter.dart';
import 'package:wger/powersync/api_client.dart';
import 'package:wger/powersync/connector.dart';

import '../helpers/in_memory_drift.dart';
import 'connector_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  // A rejected upload surfaces via handleError -> showGeneralErrorDialog, which
  // reads navigatorKey.currentContext. Initialising the binding makes that
  // return null (no widget tree) so the dialog is skipped instead of throwing.
  TestWidgetsFlutterBinding.ensureInitialized();

  late DjangoConnector connector;

  setUp(() {
    connector = DjangoConnector(baseUrl: 'http://example.invalid', apiClient: MockApiClient());
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
        {'notes': 'leg day', 'impression': '1'},
        '42',
      );
      expect(out, {'id': '42', 'notes': 'leg day', 'impression': '1'});
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

    test('keeps `external_id`, which is a value column and not a foreign key', () {
      final out = connector.genericTransform(
        'measurements_measurement',
        {'external_id': 'abc-123', 'category_id': 5},
        '1',
      );
      expect(out['external_id'], 'abc-123');
      expect(out['category'], 5);
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

      test('leaves the session timestamps untouched', () {
        // The session no longer has a date-only column, both timestamps go to
        // the server as the full ISO8601 values they are.
        final out = connector.genericTransform(
          'manager_workoutsession',
          {
            'datetime_start': '2024-11-01T18:30:00.000Z',
            'notes': 'felt great',
            'impression': '1',
          },
          '12',
        );
        expect(out['datetime_start'], '2024-11-01T18:30:00.000Z');
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
        // registry, the timestamp must round-trip unchanged.
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

      test('trims every date-only column in the Drift schema', () async {
        // The registry of date-only fields is maintained by hand, so a new
        // table backed by a Django `DateField` can be forgotten, and the push
        // then fails on a value the backend cannot parse. Derive the columns
        // from the schema instead of listing them here again.
        final db = await openTestDatabase();
        addTearDown(db.close);

        final dateOnlyColumns = <(String, String)>[];
        for (final table in db.allTables) {
          for (final column in table.$columns) {
            if (column is GeneratedColumnWithTypeConverter &&
                column.converter is DateOnlyTextConverter) {
              dateOnlyColumns.add((table.actualTableName, column.name));
            }
          }
        }
        expect(dateOnlyColumns, isNotEmpty);

        for (final (table, column) in dateOnlyColumns) {
          final out = connector.genericTransform(table, {column: '2024-11-01T00:00:00.000Z'}, '1');
          expect(
            out[column],
            '2024-11-01',
            reason: '$table.$column is not registered as a date-only field',
          );
        }
      });
    });
  });

  group('fetchCredentials', () {
    /// Probe client answering 200 for any liveness probe, so the endpoint
    /// resolution keeps whatever URL the token response advertised.
    MockClient anyLivenessOk() => MockClient(
      (request) async => request.url.path.endsWith('/probes/liveness')
          ? http.Response('{"ready":true}', 200)
          : http.Response('not found', 404),
    );

    /// Probe client answering 200 only for [probeUrl].
    MockClient liveOnlyAt(String probeUrl) => MockClient(
      (request) async => request.url.toString() == probeUrl
          ? http.Response('{"ready":true}', 200)
          : http.Response('not found', 404),
    );

    test('builds PowerSyncCredentials with userId from sub and expiresAt from exp', () async {
      final mockApi = MockApiClient();
      final connector = DjangoConnector(
        baseUrl: 'http://example.invalid',
        apiClient: mockApi,
        client: anyLivenessOk(),
      );
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
      final connector = DjangoConnector(
        baseUrl: 'http://example.invalid',
        apiClient: mockApi,
        client: anyLivenessOk(),
      );
      final jwt = makeJwt({'sub': 42, 'exp': 1700000000});
      when(mockApi.getPowersyncToken()).thenAnswer(
        (_) async => {'token': jwt, 'powersync_url': 'https://ps.example.com'},
      );

      final creds = await connector.fetchCredentials();

      expect(creds!.userId, '42');
    });

    test('still produces credentials when JWT is opaque (userId/expiresAt null)', () async {
      final mockApi = MockApiClient();
      final connector = DjangoConnector(
        baseUrl: 'http://example.invalid',
        apiClient: mockApi,
        client: anyLivenessOk(),
      );
      when(mockApi.getPowersyncToken()).thenAnswer(
        (_) async => {'token': 'not.a.jwt', 'powersync_url': 'https://ps.example.com'},
      );

      final creds = await connector.fetchCredentials();

      expect(creds!.endpoint, 'https://ps.example.com');
      expect(creds.token, 'not.a.jwt');
      expect(creds.userId, isNull);
      expect(creds.expiresAt, isNull);
    });

    test('falls back to <baseUrl>/ps/ when powersync_url does not answer the probe', () async {
      final mockApi = MockApiClient();
      final connector = DjangoConnector(
        baseUrl: 'http://example.invalid',
        apiClient: mockApi,
        client: liveOnlyAt('http://example.invalid/ps/probes/liveness'),
      );
      final jwt = makeJwt({'sub': 'user-42', 'exp': 1700000000});
      when(mockApi.getPowersyncToken()).thenAnswer(
        (_) async => {'token': jwt, 'powersync_url': 'http://localhost/ps/'},
      );

      final creds = await connector.fetchCredentials();

      expect(creds!.endpoint, 'http://example.invalid/ps/');
    });

    test('falls back to <baseUrl>/ps/ when powersync_url is missing', () async {
      final mockApi = MockApiClient();
      final connector = DjangoConnector(
        baseUrl: 'http://example.invalid',
        apiClient: mockApi,
        client: liveOnlyAt('http://example.invalid/ps/probes/liveness'),
      );
      final jwt = makeJwt({'sub': 'user-42', 'exp': 1700000000});
      when(mockApi.getPowersyncToken()).thenAnswer(
        (_) async => {'token': jwt},
      );

      final creds = await connector.fetchCredentials();

      expect(creds!.endpoint, 'http://example.invalid/ps/');
    });

    test('probes once per powersync_url value, again when it changes', () async {
      final probes = <String>[];
      final mockApi = MockApiClient();
      final connector = DjangoConnector(
        baseUrl: 'http://example.invalid',
        apiClient: mockApi,
        client: MockClient((request) async {
          probes.add(request.url.toString());
          return http.Response('{"ready":true}', 200);
        }),
      );
      final jwt = makeJwt({'sub': 'u', 'exp': 1700000000});
      when(mockApi.getPowersyncToken()).thenAnswer(
        (_) async => {'token': jwt, 'powersync_url': 'https://ps.example.com'},
      );

      await connector.fetchCredentials();
      await connector.fetchCredentials();
      expect(probes, ['https://ps.example.com/probes/liveness']);

      when(mockApi.getPowersyncToken()).thenAnswer(
        (_) async => {'token': jwt, 'powersync_url': 'https://other.example.com'},
      );
      final creds = await connector.fetchCredentials();

      expect(probes, hasLength(2));
      expect(creds!.endpoint, 'https://other.example.com');
    });

    test('does not cache a failed resolution', () async {
      final probes = <String>[];
      final mockApi = MockApiClient();
      final connector = DjangoConnector(
        baseUrl: 'http://example.invalid',
        apiClient: mockApi,
        client: MockClient((request) async {
          probes.add(request.url.toString());
          return http.Response('not found', 404);
        }),
      );
      final jwt = makeJwt({'sub': 'u', 'exp': 1700000000});
      when(mockApi.getPowersyncToken()).thenAnswer(
        (_) async => {'token': jwt, 'powersync_url': 'https://ps.example.com'},
      );

      expect(await connector.fetchCredentials(), isNull);
      expect(await connector.fetchCredentials(), isNull);

      // Both candidates probed on both attempts: no negative caching.
      expect(probes, hasLength(4));
    });

    test('returns null when the backend is unreachable', () async {
      final mockApi = MockApiClient();
      final connector = DjangoConnector(baseUrl: 'http://example.invalid', apiClient: mockApi);
      when(
        mockApi.getPowersyncToken(),
      ).thenThrow(http.ClientException('Connection refused'));

      expect(await connector.fetchCredentials(), isNull);
    });

    test('anchors expiresAt to the local clock via the token lifetime', () async {
      final mockApi = MockApiClient();
      final connector = DjangoConnector(
        baseUrl: 'http://example.invalid',
        apiClient: mockApi,
        client: anyLivenessOk(),
      );
      // iat/exp lie far in the past; only their 600 s difference may matter.
      final jwt = makeJwt({'sub': 'u', 'iat': 1700000000, 'exp': 1700000600});
      when(mockApi.getPowersyncToken()).thenAnswer(
        (_) async => {'token': jwt, 'powersync_url': 'https://ps.example.com'},
      );

      final creds = await connector.fetchCredentials();

      final expected = DateTime.now().toUtc().add(const Duration(seconds: 600));
      expect(creds!.expiresAt!.difference(expected).abs(), lessThan(const Duration(seconds: 5)));
    });

    group('unreachable-backend logging', () {
      late MockApiClient mockApi;
      late DjangoConnector connector;
      late List<LogRecord> records;

      setUp(() {
        mockApi = MockApiClient();
        connector = DjangoConnector(
          baseUrl: 'http://example.invalid',
          apiClient: mockApi,
          client: anyLivenessOk(),
        );
        records = [];
        final sub = Logger.root.onRecord.listen(records.add);
        addTearDown(sub.cancel);
      });

      Iterable<LogRecord> infoLines(String needle) =>
          records.where((r) => r.level == Level.INFO && r.message.contains(needle));

      test('logs the outage at INFO once, not per retry', () async {
        when(
          mockApi.getPowersyncToken(),
        ).thenThrow(http.ClientException('Connection refused'));

        await connector.fetchCredentials();
        await connector.fetchCredentials();
        await connector.fetchCredentials();

        expect(infoLines('backend unreachable'), hasLength(1));
      });

      test('logs recovery once the fetch succeeds again', () async {
        when(
          mockApi.getPowersyncToken(),
        ).thenThrow(const SocketException('Network is unreachable'));
        await connector.fetchCredentials();

        final jwt = makeJwt({'sub': 'u', 'iat': 1700000000, 'exp': 1700000600});
        when(mockApi.getPowersyncToken()).thenAnswer(
          (_) async => {'token': jwt, 'powersync_url': 'https://ps.example.com'},
        );
        await connector.fetchCredentials();

        expect(infoLines('reachable again'), hasLength(1));
      });

      test('a new outage after recovery is logged immediately again', () async {
        when(
          mockApi.getPowersyncToken(),
        ).thenThrow(http.ClientException('Connection refused'));
        await connector.fetchCredentials();

        final jwt = makeJwt({'sub': 'u', 'iat': 1700000000, 'exp': 1700000600});
        when(mockApi.getPowersyncToken()).thenAnswer(
          (_) async => {'token': jwt, 'powersync_url': 'https://ps.example.com'},
        );
        await connector.fetchCredentials();

        when(
          mockApi.getPowersyncToken(),
        ).thenThrow(http.ClientException('Connection refused'));
        await connector.fetchCredentials();

        expect(infoLines('backend unreachable'), hasLength(2));
      });

      test('logs the endpoint once, again only when it changes', () async {
        final jwt = makeJwt({'sub': 'u', 'iat': 1700000000, 'exp': 1700000600});
        when(mockApi.getPowersyncToken()).thenAnswer(
          (_) async => {'token': jwt, 'powersync_url': 'https://ps.example.com'},
        );
        await connector.fetchCredentials();
        await connector.fetchCredentials();

        when(mockApi.getPowersyncToken()).thenAnswer(
          (_) async => {'token': jwt, 'powersync_url': 'https://other.example.com'},
        );
        await connector.fetchCredentials();

        expect(infoLines('endpoint https://ps.example.com'), hasLength(1));
        expect(infoLines('endpoint https://other.example.com'), hasLength(1));
      });

      test('does not log recovery when there was no outage', () async {
        final jwt = makeJwt({'sub': 'u', 'iat': 1700000000, 'exp': 1700000600});
        when(mockApi.getPowersyncToken()).thenAnswer(
          (_) async => {'token': jwt, 'powersync_url': 'https://ps.example.com'},
        );

        await connector.fetchCredentials();

        expect(infoLines('reachable again'), isEmpty);
      });
    });
  });

  group('processTransaction', () {
    late MockApiClient api;
    late DjangoConnector conn;

    // Mirrors PowerSync clearing the op from the local queue: set to true once
    // transaction.complete() runs.
    bool completed = false;

    setUp(() {
      api = MockApiClient();
      conn = DjangoConnector(baseUrl: 'http://example.invalid', apiClient: api);
      completed = false;
    });

    CrudTransaction txWithAll(List<CrudEntry> entries) => CrudTransaction(
      transactionId: 1,
      crud: entries,
      complete: ({String? writeCheckpoint}) async {
        completed = true;
      },
    );

    CrudTransaction txWith(CrudEntry entry) => txWithAll([entry]);

    test('uploads a put through the transform and completes on success', () async {
      when(api.upsert(any)).thenAnswer((_) async => http.Response('{}', 200));

      await conn.processTransaction(
        txWith(CrudEntry(1, UpdateType.put, 'manager_routine', 'r1', 1, {'name': 'Push'})),
      );

      final record = verify(api.upsert(captureAny)).captured.single;
      expect(record, {
        'table': 'manager_routine',
        'data': {'id': 'r1', 'name': 'Push'},
      });
      expect(completed, isTrue);
    });

    test('routes patch to update and delete to delete', () async {
      when(api.update(any)).thenAnswer((_) async => http.Response('{}', 200));
      await conn.processTransaction(
        txWith(CrudEntry(1, UpdateType.patch, 'manager_routine', 'r1', 1, {'name': 'Pull'})),
      );
      verify(api.update(any)).called(1);

      when(api.delete(any)).thenAnswer((_) async => http.Response('{}', 200));
      await conn.processTransaction(
        txWith(CrudEntry(2, UpdateType.delete, 'manager_routine', 'r1', 1, null)),
      );
      verify(api.delete(any)).called(1);
    });

    test('completes the transaction even when the backend rejects the op', () async {
      // The key anti-poison-pill behaviour: a 200 with an `error` body is a
      // permanent rejection. processTransaction must not rethrow (that would
      // retry forever) and must still complete the transaction so the op leaves
      // the queue. PowerSync then reverts the local row on the next checkpoint.
      when(api.upsert(any)).thenAnswer(
        (_) async => http.Response(json.encode({'error': 'invalid', 'details': 'bad'}), 200),
      );

      await conn.processTransaction(
        txWith(CrudEntry(1, UpdateType.put, 'manager_routine', 'r1', 1, {'name': 'x'})),
      );

      expect(completed, isTrue);
    });

    test('a rejected op does not stop the ops behind it', () async {
      // One bad op must not block the queue: the rest of the transaction is
      // still sent and the transaction completes.
      when(api.upsert(any)).thenAnswer(
        (_) async => http.Response(json.encode({'error': 'invalid'}), 200),
      );
      when(api.update(any)).thenAnswer((_) async => http.Response('{}', 200));

      await conn.processTransaction(
        txWithAll([
          CrudEntry(1, UpdateType.put, 'manager_routine', 'r1', 1, {'name': 'x'}),
          CrudEntry(2, UpdateType.patch, 'manager_routine', 'r2', 1, {'name': 'y'}),
        ]),
      );

      verify(api.update(any)).called(1);
      expect(completed, isTrue);
    });

    test('a retryable op leaves the whole transaction queued for a replay', () async {
      // The op ahead of it was already sent, so the replay re-sends it: this is
      // the at-least-once delivery the backend handlers have to be idempotent
      // for.
      when(api.upsert(any)).thenAnswer((_) async => http.Response('{}', 200));
      when(api.update(any)).thenAnswer((_) async => http.Response('', 503));

      await expectLater(
        conn.processTransaction(
          txWithAll([
            CrudEntry(1, UpdateType.put, 'manager_routine', 'r1', 1, {'name': 'x'}),
            CrudEntry(2, UpdateType.patch, 'manager_routine', 'r2', 1, {'name': 'y'}),
          ]),
        ),
        throwsA(isA<RetryableUploadException>()),
      );

      verify(api.upsert(any)).called(1);
      expect(completed, isFalse);
    });

    test('rethrows and leaves the transaction queued when the backend is unreachable', () async {
      when(api.upsert(any)).thenThrow(http.ClientException('Connection refused'));

      await expectLater(
        conn.processTransaction(
          txWith(CrudEntry(1, UpdateType.put, 'manager_routine', 'r1', 1, {'name': 'x'})),
        ),
        throwsA(isA<http.ClientException>()),
      );
      // Not completed: the op stays queued for PowerSync to retry once online.
      expect(completed, isFalse);
    });

    test('rethrows RetryableUploadException on transient/retryable statuses', () async {
      // Server errors, gateway timeout, rate limiting and a non-recoverable 401
      // are retried: throw so PowerSync keeps the transaction queued. Mirrors
      // the ClientException test above.
      for (final status in [500, 502, 503, 504, 408, 429, 401]) {
        completed = false;
        when(api.upsert(any)).thenAnswer((_) async => http.Response('', status));

        await expectLater(
          conn.processTransaction(
            txWith(CrudEntry(1, UpdateType.put, 'manager_routine', 'r1', 1, {'name': 'x'})),
          ),
          throwsA(isA<RetryableUploadException>()),
          reason: 'status $status should be retried',
        );
        expect(completed, isFalse, reason: 'status $status must stay queued');
      }
    });

    test('reports and completes on unexpected permanent client errors', () async {
      // Retrying these would not help, so the op is surfaced and discarded
      // rather than blocking the queue. 403 is here, not in the retry set: the
      // backend delivers ownership refusals as 200 + {error}, so a real 403 is
      // a permanent refusal.
      for (final status in [400, 403, 404, 409, 422]) {
        completed = false;
        when(api.upsert(any)).thenAnswer((_) async => http.Response('', status));

        await conn.processTransaction(
          txWith(CrudEntry(1, UpdateType.put, 'manager_routine', 'r$status', 1, {'name': 'x'})),
        );

        expect(completed, isTrue, reason: 'status $status must not block the queue');
      }
    });

    test('completes on a 2xx with an empty body', () async {
      when(api.upsert(any)).thenAnswer((_) async => http.Response('', 200));

      await conn.processTransaction(
        txWith(CrudEntry(1, UpdateType.put, 'manager_routine', 'r1', 1, {'name': 'x'})),
      );

      expect(completed, isTrue);
    });
  });
}
