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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/providers/app_settings_notifier.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/auth_state.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/media_url_prefix_notifier.dart';
import 'package:wger/providers/wger_base.dart';

import 'media_url_prefix_notifier_test.mocks.dart';

/// Replaces the real [AuthNotifier] with one that returns a fixed
/// [AuthState] from build(). Anything that watches [authProvider] sees
/// the requested status without going through the real auto-login flow.
class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._initial);
  final AuthState _initial;

  @override
  Future<AuthState> build() async => _initial;
}

@GenerateMocks([SharedPreferencesAsync, WgerBaseProvider])
void main() {
  group('extractMediaPrefix (pure function)', () {
    test('extracts the prefix from a typical wger.de exercise image URL', () {
      final prefix = extractMediaPrefix({
        'results': [
          {'image': 'https://wger.de/media/exercise-images/91/Crunches-1.png'},
        ],
      });
      expect(prefix, 'https://wger.de/media/');
    });

    test('extracts a CDN-fronted prefix', () {
      final prefix = extractMediaPrefix({
        'results': [
          {'image': 'https://cdn.wger.de/media/exercise-images/91/foo.png'},
        ],
      });
      expect(prefix, 'https://cdn.wger.de/media/');
    });

    test('extracts a non-/media/ prefix (custom MEDIA_URL deployment)', () {
      final prefix = extractMediaPrefix({
        'results': [
          {'image': 'https://wger.example.com/static_media/exercise-images/91/foo.png'},
        ],
      });
      expect(prefix, 'https://wger.example.com/static_media/');
    });

    test('returns null when results is empty', () {
      expect(extractMediaPrefix({'results': []}), isNull);
    });

    test('returns null when results key is missing entirely', () {
      expect(extractMediaPrefix({'count': 0}), isNull);
    });

    test('returns null when the image field is missing or null', () {
      expect(
        extractMediaPrefix({
          'results': [
            {'image': null},
          ],
        }),
        isNull,
      );
    });

    test('returns null when the URL does not contain the marker', () {
      // Pathological case: server returned an unexpected URL shape we
      // can't parse. Falling back to the default prefix is correct.
      expect(
        extractMediaPrefix({
          'results': [
            {'image': 'https://wger.de/media/some-other-folder/foo.png'},
          ],
        }),
        isNull,
      );
    });

    test('returns null for a non-Map response body', () {
      expect(extractMediaPrefix(null), isNull);
      expect(extractMediaPrefix('oops'), isNull);
      expect(extractMediaPrefix(<dynamic>[]), isNull);
    });
  });

  group('MediaUrlPrefixNotifier', () {
    late MockSharedPreferencesAsync mockPrefs;
    late MockWgerBaseProvider mockBase;

    /// Builds a container wired to the in-test mocks. [authStatus]
    /// controls what the auth-listener inside the notifier sees.
    ProviderContainer makeContainer({AuthStatus authStatus = AuthStatus.loggedIn}) {
      final c = ProviderContainer(
        overrides: [
          appSettingsPrefsProvider.overrideWithValue(mockPrefs),
          wgerBaseProvider.overrideWithValue(mockBase),
          authProvider.overrideWith(
            () => _FixedAuthNotifier(AuthState(status: authStatus)),
          ),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    /// Stubs makeUrl + fetch on the WgerBaseProvider so probe()'s HTTP
    /// path runs against the given canned response.
    void stubFetch({required dynamic responseBody}) {
      final uri = Uri.parse('https://example/api/v2/exerciseimage/?limit=1');
      when(mockBase.makeUrl(any, query: anyNamed('query'))).thenReturn(uri);
      when(mockBase.fetch(uri)).thenAnswer((_) async => responseBody);
    }

    setUp(() {
      mockPrefs = MockSharedPreferencesAsync();
      mockBase = MockWgerBaseProvider();

      // Defaults: prefs empty, authenticated base provider.
      when(mockPrefs.getString(any)).thenAnswer((_) async => null);
      when(mockPrefs.setString(any, any)).thenAnswer((_) async {});
      when(mockPrefs.remove(any)).thenAnswer((_) async {});
      when(mockBase.serverUrl).thenReturn('https://example');
      // Default fetch, empty response so the auto-probe in build is
      // a harmless no-op for tests that don't care about it.
      stubFetch(responseBody: {'results': []});
    });

    test('build returns the cached value when prefs has one', () async {
      when(
        mockPrefs.getString(PREFS_MEDIA_URL_PREFIX),
      ).thenAnswer((_) async => 'https://wger.de/media/');

      final container = makeContainer();
      final value = await container.read(mediaUrlPrefixProvider.future);

      expect(value, 'https://wger.de/media/');
      // Cache hit short-circuits the probe.
      verifyNever(mockBase.fetch(any));
    });

    test('build does not probe when the user is logged out', () async {
      final container = makeContainer(authStatus: AuthStatus.loggedOut);

      final value = await container.read(mediaUrlPrefixProvider.future);

      expect(value, isNull);
      verifyNever(mockBase.fetch(any));
    });

    test('probe persists the extracted prefix and updates state', () async {
      stubFetch(
        responseBody: {
          'results': [
            {'image': 'https://cdn.example.com/media/exercise-images/91/foo.png'},
          ],
        },
      );

      final container = makeContainer();
      // build() triggers an auto-probe in the background. We also
      // drive the notifier explicitly for ordering, both calls are
      // idempotent. Verify uses no .called() so we accept either one
      // or two invocations.
      await container.read(mediaUrlPrefixProvider.future);
      await container.read(mediaUrlPrefixProvider.notifier).probe();

      expect(
        container.read(mediaUrlPrefixProvider).asData?.value,
        'https://cdn.example.com/media/',
      );
      verify(
        mockPrefs.setString(PREFS_MEDIA_URL_PREFIX, 'https://cdn.example.com/media/'),
      );
    });

    test("probe is a no-op when the response can't be parsed", () async {
      stubFetch(responseBody: {'results': []});

      final container = makeContainer();
      await container.read(mediaUrlPrefixProvider.future);
      await container.read(mediaUrlPrefixProvider.notifier).probe();

      expect(container.read(mediaUrlPrefixProvider).asData?.value, isNull);
      verifyNever(mockPrefs.setString(any, any));
    });

    test('probe swallows fetch errors and leaves state alone', () async {
      when(
        mockBase.makeUrl(any, query: anyNamed('query')),
      ).thenReturn(Uri.parse('https://example/x'));
      when(mockBase.fetch(any)).thenThrow(Exception('network down'));

      final container = makeContainer();
      await container.read(mediaUrlPrefixProvider.future);
      await container.read(mediaUrlPrefixProvider.notifier).probe();

      expect(container.read(mediaUrlPrefixProvider).asData?.value, isNull);
      verifyNever(mockPrefs.setString(any, any));
    });

    test('probe does not write back when the user logged out during the await', () async {
      // fetch returns a valid prefix, but auth is loggedOut throughout.
      // The notifier must not persist the value.
      stubFetch(
        responseBody: {
          'results': [
            {'image': 'https://wger.de/media/exercise-images/1/foo.png'},
          ],
        },
      );

      final container = makeContainer(authStatus: AuthStatus.loggedOut);
      await container.read(mediaUrlPrefixProvider.future);
      await container.read(mediaUrlPrefixProvider.notifier).probe();

      expect(container.read(mediaUrlPrefixProvider).asData?.value, isNull);
      verifyNever(mockPrefs.setString(any, any));
    });

    test('clear wipes both state and persisted value', () async {
      when(
        mockPrefs.getString(PREFS_MEDIA_URL_PREFIX),
      ).thenAnswer((_) async => 'https://wger.de/media/');

      final container = makeContainer();
      await container.read(mediaUrlPrefixProvider.future);
      // Sanity check that we started with a value.
      expect(
        container.read(mediaUrlPrefixProvider).asData?.value,
        'https://wger.de/media/',
      );

      await container.read(mediaUrlPrefixProvider.notifier).clear();

      expect(container.read(mediaUrlPrefixProvider).asData?.value, isNull);
      verify(mockPrefs.remove(PREFS_MEDIA_URL_PREFIX)).called(1);
    });
  });
}
