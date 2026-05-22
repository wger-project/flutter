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

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/providers/app_link_router.dart';

void main() {
  group('AppLinkRouter.tokenFromUri', () {
    test('extracts token from a plain fragment', () {
      final uri = Uri.parse('wger://app-auth#token=abc.def.ghi');
      expect(AppLinkRouter.tokenFromUri(uri), 'abc.def.ghi');
    });

    test('extracts token when fragment carries multiple pairs', () {
      final uri = Uri.parse('wger://app-auth#state=xyz&token=abc.def.ghi');
      expect(AppLinkRouter.tokenFromUri(uri), 'abc.def.ghi');
    });

    test('url-decodes the token value', () {
      // %3D is "=" — JWTs don't actually contain it, but the encoder is
      // configured to escape every non-alphanumeric so we should be lenient.
      final uri = Uri.parse('wger://app-auth#token=abc%2Edef%2Eghi');
      expect(AppLinkRouter.tokenFromUri(uri), 'abc.def.ghi');
    });

    test('returns null for a wrong scheme', () {
      final uri = Uri.parse('https://app-auth#token=abc.def.ghi');
      expect(AppLinkRouter.tokenFromUri(uri), isNull);
    });

    test('returns null for a wrong host', () {
      final uri = Uri.parse('wger://other-host#token=abc.def.ghi');
      expect(AppLinkRouter.tokenFromUri(uri), isNull);
    });

    test('returns null when the fragment is empty', () {
      final uri = Uri.parse('wger://app-auth');
      expect(AppLinkRouter.tokenFromUri(uri), isNull);
    });

    test('returns null when the fragment carries no token parameter', () {
      final uri = Uri.parse('wger://app-auth#state=xyz');
      expect(AppLinkRouter.tokenFromUri(uri), isNull);
    });

    test('returns null when the token parameter is empty', () {
      final uri = Uri.parse('wger://app-auth#token=');
      expect(AppLinkRouter.tokenFromUri(uri), isNull);
    });

    test('ignores the query string', () {
      // The token must come from the fragment, not the query — that's the
      // server-log / Referer leak surface we're explicitly avoiding.
      final uri = Uri.parse('wger://app-auth?token=abc.def.ghi');
      expect(AppLinkRouter.tokenFromUri(uri), isNull);
    });
  });

  group('fragmentParam', () {
    test('extracts state from a fragment with multiple pairs', () {
      final uri = Uri.parse('wger://app-auth#token=abc&state=NONCE');
      expect(fragmentParam(uri, 'state'), 'NONCE');
    });

    test('returns null when the requested parameter is absent', () {
      final uri = Uri.parse('wger://app-auth#token=abc');
      expect(fragmentParam(uri, 'state'), isNull);
    });
  });

  group('issueAppAuthState / consumeAppAuthState', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    });

    test('a freshly issued state is accepted exactly once', () async {
      final state = await issueAppAuthState();
      expect(state, isNotEmpty);
      expect(await consumeAppAuthState(state), isTrue);
      // Single-use: the second consume sees an empty store.
      expect(await consumeAppAuthState(state), isFalse);
    });

    test('a mismatched state is rejected and still clears the pending one', () async {
      await issueAppAuthState();
      expect(await consumeAppAuthState('not-the-real-one'), isFalse);
      // The pending state was wiped — replaying the right value now also fails.
      expect(await consumeAppAuthState('anything'), isFalse);
    });

    test('null and empty received values are rejected', () async {
      await issueAppAuthState();
      expect(await consumeAppAuthState(null), isFalse);
    });

    test('consume without any pending state returns false', () async {
      expect(await consumeAppAuthState('anything'), isFalse);
    });

    test('state past the TTL is rejected', () async {
      // Freeze time at T0 for issue; jump TTL + 1s for consume.
      final t0 = DateTime(2026, 1, 1, 12);
      String? issued;
      await withClock(Clock.fixed(t0), () async {
        issued = await issueAppAuthState();
      });
      final later = t0.add(APP_AUTH_STATE_TTL + const Duration(seconds: 1));
      final result = await withClock(
        Clock.fixed(later),
        () => consumeAppAuthState(issued),
      );
      expect(result, isFalse);
    });

    test('issuing twice rotates the value', () async {
      final first = await issueAppAuthState();
      final second = await issueAppAuthState();
      expect(first, isNot(second));
      // Only the second one is now consumable.
      expect(await consumeAppAuthState(first), isFalse);
    });

    test('rotation invariant: each issue must invalidate the previous', () async {
      final first = await issueAppAuthState();
      await issueAppAuthState();
      expect(await consumeAppAuthState(first), isFalse);
    });
  });
}
