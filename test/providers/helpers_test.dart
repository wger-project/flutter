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
import 'package:wger/providers/helpers.dart';

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
        // Useful when the REST API has already absolutised the URL — we must
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
}
