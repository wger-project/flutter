/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:version/version.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/providers/auth_credentials_storage.dart';
import 'package:wger/providers/secure_token_storage.dart';
import 'package:wger/providers/server_gating.dart';

/// The version gates don't touch storage; this stand-in satisfies the
/// constructor without pulling in secure-storage plumbing.
class _FakeSecureTokenStorage extends Fake implements SecureTokenStorage {}

ServerGating _gatingReturning(http.Response response) => ServerGating(
  MockClient((_) async => response),
  AuthCredentialsStorage(_FakeSecureTokenStorage()),
);

void main() {
  group('min server version check', () {
    final minVersion = Version.parse(MIN_SERVER_VERSION);
    final aboveMin = Version(minVersion.major, minVersion.minor + 1, 0).toString();
    const atMin = MIN_SERVER_VERSION;
    final belowMin = Version(minVersion.major, minVersion.minor - 1, 0).toString();

    test('server version greater than min, no update needed', () {
      expect(serverUpdateRequired(aboveMin), false);
    });

    test('server version equal to min, no update needed', () {
      expect(serverUpdateRequired(atMin), false);
    });

    test('server version less than min, update needed', () {
      expect(serverUpdateRequired(belowMin), true);
    });

    test('server version with patch component less than min, update needed', () {
      expect(serverUpdateRequired('$belowMin.9'), true);
    });

    test('server version with patch component greater than min, no update needed', () {
      expect(serverUpdateRequired('$atMin.1'), false);
    });

    test('null server version, returns false (lenient, no lockout)', () {
      expect(serverUpdateRequired(null), false);
    });

    test('server version with pre-release suffix, still parsed correctly', () {
      expect(serverUpdateRequired('$aboveMin.0-beta'), false);
    });

    test('server version with Python alpha suffix (e.g. 1.2.3.0a2), parsed correctly', () {
      expect(serverUpdateRequired('$aboveMin.0a2'), false);
    });

    test('server version with Python alpha suffix below min, blocked', () {
      expect(serverUpdateRequired('$belowMin.0a2'), true);
    });

    test('server version with build metadata suffix, still parsed correctly', () {
      expect(serverUpdateRequired('$belowMin.0 (git-abc1234)'), true);
    });

    test('completely unparseable server version, returns false (lenient)', () {
      expect(serverUpdateRequired('unknown'), false);
    });
  });

  // A transient blip on a startup version endpoint must skip the gate, not
  // throw out of auto-login and strand the user on an unrecoverable error.
  group('version gates are lenient on transient failures', () {
    const serverUrl = 'https://wger.example';

    test('fetchServerVersion: null on a 5xx HTML blip', () async {
      final gating = _gatingReturning(http.Response('<html>502 Bad Gateway</html>', 502));
      expect(await gating.fetchServerVersion(serverUrl), isNull);
    });

    test('fetchServerVersion: null on an empty body', () async {
      final gating = _gatingReturning(http.Response('', 200));
      expect(await gating.fetchServerVersion(serverUrl), isNull);
    });

    test('fetchServerVersion: null when the request fails outright', () async {
      final gating = ServerGating(
        MockClient((_) async => throw http.ClientException('boom')),
        AuthCredentialsStorage(_FakeSecureTokenStorage()),
      );
      expect(await gating.fetchServerVersion(serverUrl), isNull);
    });

    test('fetchServerVersion: returns the version on a valid 200', () async {
      final gating = _gatingReturning(http.Response('"2.5.0"', 200));
      expect(await gating.fetchServerVersion(serverUrl), '2.5.0');
    });

    test('applicationUpdateRequired: false on a 5xx blip', () async {
      final gating = _gatingReturning(http.Response('<html>500</html>', 500));
      expect(await gating.applicationUpdateRequired(serverUrl, '1.0.0'), false);
    });

    test('applicationUpdateRequired: false on an empty body', () async {
      final gating = _gatingReturning(http.Response('', 200));
      expect(await gating.applicationUpdateRequired(serverUrl, '1.0.0'), false);
    });

    test('applicationUpdateRequired: true when the server demands a newer build', () async {
      final gating = _gatingReturning(http.Response('"99.0.0"', 200));
      expect(await gating.applicationUpdateRequired(serverUrl, '1.0.0'), true);
    });
  });
}
