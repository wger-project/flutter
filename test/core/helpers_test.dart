/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/helpers.dart';

void main() {
  group('mediaUri', () {
    group('null / empty input', () {
      test('returns null for a null path', () {
        expect(mediaUri('https://wger.de', null), isNull);
      });

      test('returns null for an empty path', () {
        expect(mediaUri('https://wger.de', ''), isNull);
      });
    });

    group('relative paths (the common case)', () {
      test('builds an https URL for a typical Django ImageField value', () {
        expect(
          mediaUri('https://wger.de', 'ingredients/42/foo.jpg').toString(),
          'https://wger.de/media/ingredients/42/foo.jpg',
        );
      });

      test('preserves nested subdirectories in the path', () {
        expect(
          mediaUri('https://wger.de', 'exercise-images/2026/04/foo.png').toString(),
          'https://wger.de/media/exercise-images/2026/04/foo.png',
        );
      });

      test('strips a leading slash from the relative path to avoid //media//', () {
        expect(
          mediaUri('https://wger.de', '/ingredients/42/foo.jpg').toString(),
          'https://wger.de/media/ingredients/42/foo.jpg',
        );
      });
    });

    group('server URL variants', () {
      test('handles a trailing slash on the server URL', () {
        expect(
          mediaUri('https://wger.de/', 'ingredients/42/foo.jpg').toString(),
          'https://wger.de/media/ingredients/42/foo.jpg',
        );
      });

      test('preserves a non-default port (dev / self-hosted setups)', () {
        expect(
          mediaUri('http://localhost:8000', 'ingredients/42/foo.jpg').toString(),
          'http://localhost:8000/media/ingredients/42/foo.jpg',
        );
      });

      test('keeps a server-side subpath (wger hosted under /wger/)', () {
        expect(
          mediaUri('https://example.com/wger', 'ingredients/42/foo.jpg').toString(),
          'https://example.com/wger/media/ingredients/42/foo.jpg',
        );
      });

      test('keeps a server-side subpath with trailing slash', () {
        expect(
          mediaUri('https://example.com/wger/', 'ingredients/42/foo.jpg').toString(),
          'https://example.com/wger/media/ingredients/42/foo.jpg',
        );
      });

      test('preserves http scheme (insecure dev setups)', () {
        expect(
          mediaUri('http://wger.local', 'ingredients/42/foo.jpg')?.scheme,
          'http',
        );
      });
    });

    group('already-absolute URLs (CDN / REST passthrough)', () {
      test('returns an https URL unchanged when the path already has a scheme', () {
        const cdn = 'https://cdn.wger.de/media/ingredients/42/foo.jpg';
        expect(mediaUri('https://wger.de', cdn).toString(), cdn);
      });

      test('returns an http URL unchanged', () {
        const cdn = 'http://images.wger.de/foo.jpg';
        expect(mediaUri('https://wger.de', cdn).toString(), cdn);
      });

      test('does not prepend the server URL for absolute URLs on different hosts', () {
        // Useful when the REST API has already absolutised the URL, we must
        // not double-prefix with the local server.
        final result = mediaUri('https://wger.de', 'https://other.example.com/x.jpg');
        expect(result?.host, 'other.example.com');
      });
    });

    group('absolutePrefix (probed value, overrides the default)', () {
      test('uses the probed prefix instead of building from serverUrl', () {
        expect(
          mediaUri(
            'https://wger.de',
            'ingredients/42/foo.jpg',
            absolutePrefix: 'https://cdn.wger.de/media/',
          ).toString(),
          'https://cdn.wger.de/media/ingredients/42/foo.jpg',
        );
      });

      test('appends a missing trailing slash to the prefix', () {
        expect(
          mediaUri(
            'https://wger.de',
            'ingredients/42/foo.jpg',
            absolutePrefix: 'https://cdn.wger.de/media',
          ).toString(),
          'https://cdn.wger.de/media/ingredients/42/foo.jpg',
        );
      });

      test('strips a leading slash from the relative path with a probed prefix', () {
        expect(
          mediaUri(
            'https://wger.de',
            '/ingredients/42/foo.jpg',
            absolutePrefix: 'https://cdn.wger.de/media/',
          ).toString(),
          'https://cdn.wger.de/media/ingredients/42/foo.jpg',
        );
      });

      test('handles a non-/media/ MEDIA_URL via the probed prefix', () {
        expect(
          mediaUri(
            'https://wger.de',
            'exercise-images/91/foo.png',
            absolutePrefix: 'https://wger.de/static_media/',
          ).toString(),
          'https://wger.de/static_media/exercise-images/91/foo.png',
        );
      });

      test('falls back to the default when prefix is empty', () {
        expect(
          mediaUri(
            'https://wger.de',
            'ingredients/42/foo.jpg',
            absolutePrefix: '',
          ).toString(),
          'https://wger.de/media/ingredients/42/foo.jpg',
        );
      });

      test('still passes already-absolute relative paths through', () {
        // Even with a probed prefix, an absolute URL in [relativePath]
        // should not be re-prefixed.
        const cdn = 'https://other.example.com/x.jpg';
        expect(
          mediaUri('https://wger.de', cdn, absolutePrefix: 'https://wger.de/media/').toString(),
          cdn,
        );
      });
    });
  });

  group('findLivePowerSyncUrl', () {
    const serverUrl = 'https://wger.example.com';

    /// Client answering 200 only for the liveness probe of [liveEndpoint]
    /// (with or without its trailing slash); records every requested URL.
    MockClient liveOnlyAt(String liveEndpoint, [List<String>? requested]) {
      final probe = '$liveEndpoint${liveEndpoint.endsWith('/') ? '' : '/'}probes/liveness';
      return MockClient((request) async {
        requested?.add(request.url.toString());
        return request.url.toString() == probe
            ? http.Response('{"ready":true}', 200)
            : http.Response('not found', 404);
      });
    }

    test('uses the server-provided URL when it answers the probe', () async {
      final requested = <String>[];
      final client = liveOnlyAt('https://ps.example.com', requested);

      expect(
        await findLivePowerSyncUrl(
          client: client,
          serverUrl: serverUrl,
          provided: 'https://ps.example.com',
        ),
        'https://ps.example.com',
      );
      expect(requested, ['https://ps.example.com/probes/liveness']);
    });

    test('falls back to <serverUrl>/ps/ when the provided URL does not answer', () async {
      // The #2432 shape: SITE_URL left at its localhost default, so the
      // advertised URL points at the device itself.
      expect(
        await findLivePowerSyncUrl(
          client: liveOnlyAt('$serverUrl/ps/'),
          serverUrl: serverUrl,
          provided: 'http://localhost/ps/',
        ),
        '$serverUrl/ps/',
      );
    });

    test('falls back when probing the provided URL throws', () async {
      final client = MockClient((request) async {
        if (request.url.host == 'ps.example.com') {
          throw http.ClientException('Connection refused');
        }
        return http.Response('{"ready":true}', 200);
      });

      expect(
        await findLivePowerSyncUrl(
          client: client,
          serverUrl: serverUrl,
          provided: 'https://ps.example.com',
        ),
        '$serverUrl/ps/',
      );
    });

    test('probes only the fallback for a missing URL', () async {
      final requested = <String>[];
      final client = liveOnlyAt('$serverUrl/ps/', requested);

      expect(
        await findLivePowerSyncUrl(client: client, serverUrl: serverUrl, provided: null),
        '$serverUrl/ps/',
      );
      expect(requested, ['$serverUrl/ps/probes/liveness']);
    });

    test('skips a URL without a scheme', () async {
      final requested = <String>[];
      final client = liveOnlyAt('$serverUrl/ps/', requested);

      expect(
        await findLivePowerSyncUrl(
          client: client,
          serverUrl: serverUrl,
          provided: 'wger.example.com/ps/',
        ),
        '$serverUrl/ps/',
      );
      expect(requested, ['$serverUrl/ps/probes/liveness']);
    });

    test('returns null when no candidate answers', () async {
      expect(
        await findLivePowerSyncUrl(
          client: MockClient((_) async => http.Response('not found', 404)),
          serverUrl: serverUrl,
          provided: 'https://ps.example.com',
        ),
        isNull,
      );
    });

    test('logs failed probes at INFO with status code or exception', () async {
      final records = <LogRecord>[];
      final sub = Logger.root.onRecord.listen(records.add);
      addTearDown(sub.cancel);

      final client = MockClient((request) async {
        if (request.url.host == 'ps.example.com') {
          throw http.ClientException('Connection refused');
        }
        return http.Response('bad gateway', 502);
      });
      await findLivePowerSyncUrl(
        client: client,
        serverUrl: serverUrl,
        provided: 'https://ps.example.com',
      );

      final messages = records.where((r) => r.level == Level.INFO).map((r) => r.message);
      expect(
        messages,
        contains('PowerSync probe: https://ps.example.com/probes/liveness failed: '
            'ClientException: Connection refused'),
      );
      expect(
        messages,
        contains('PowerSync probe: $serverUrl/ps/probes/liveness returned 502'),
      );
    });

    test('keeps a sub-directory installation path in the fallback', () async {
      expect(
        await findLivePowerSyncUrl(
          client: liveOnlyAt('https://example.com/wger/ps/'),
          serverUrl: 'https://example.com/wger',
          provided: null,
        ),
        'https://example.com/wger/ps/',
      );
    });

    test('handles a trailing slash on the server URL', () async {
      expect(
        await findLivePowerSyncUrl(
          client: liveOnlyAt('$serverUrl/ps/'),
          serverUrl: '$serverUrl/',
          provided: null,
        ),
        '$serverUrl/ps/',
      );
    });
  });
}
