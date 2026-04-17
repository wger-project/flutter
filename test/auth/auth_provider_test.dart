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
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:version/version.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/providers/auth.dart';

import '../other/base_provider_test.mocks.dart';

void main() {
  late AuthProvider authProvider;
  late MockClient mockClient;

  final Uri tVersionUri = Uri(
    scheme: 'http',
    host: 'localhost',
    path: 'api/v2/min-app-version/',
  );

  setUp(() {
    mockClient = MockClient();
    authProvider = AuthProvider(mockClient);
    authProvider.serverUrl = 'http://localhost';
  });

  group('min application version check', () {
    test('app version higher than min version', () async {
      // arrange
      when(mockClient.get(tVersionUri)).thenAnswer((_) => Future(() => Response('"1.2.0"', 200)));
      final updateNeeded = await authProvider.applicationUpdateRequired('1.3.0');

      // assert
      expect(updateNeeded, false);
    });

    test('app version higher than min version - 1', () async {
      // arrange
      when(mockClient.get(tVersionUri)).thenAnswer((_) => Future(() => Response('"1.3"', 200)));
      final updateNeeded = await authProvider.applicationUpdateRequired('1.1');

      // assert
      expect(updateNeeded, true);
    });

    test('app version higher than min version - 2', () async {
      // arrange
      when(mockClient.get(tVersionUri)).thenAnswer((_) => Future(() => Response('"1.3.0"', 200)));
      final updateNeeded = await authProvider.applicationUpdateRequired('1.1');

      // assert
      expect(updateNeeded, true);
    });

    test('app version equal as min version', () async {
      // arrange
      when(mockClient.get(tVersionUri)).thenAnswer((_) => Future(() => Response('"1.3.0"', 200)));
      final updateNeeded = await authProvider.applicationUpdateRequired('1.3.0');

      // assert
      expect(updateNeeded, false);
    });
  });

  group('min server version check', () {
    final minVersion = Version.parse(MIN_SERVER_VERSION);
    final aboveMin = Version(minVersion.major, minVersion.minor + 1, 0).toString();
    const atMin = MIN_SERVER_VERSION;
    final belowMin = Version(minVersion.major, minVersion.minor - 1, 0).toString();

    test('server version greater than min — no update needed', () {
      authProvider.serverVersion = aboveMin;
      expect(authProvider.serverUpdateRequired(), false);
    });

    test('server version equal to min — no update needed', () {
      authProvider.serverVersion = atMin;
      expect(authProvider.serverUpdateRequired(), false);
    });

    test('server version less than min — update needed', () {
      authProvider.serverVersion = belowMin;
      expect(authProvider.serverUpdateRequired(), true);
    });

    test('server version with patch component less than min — update needed', () {
      authProvider.serverVersion = '$belowMin.9';
      expect(authProvider.serverUpdateRequired(), true);
    });

    test('server version with patch component greater than min — no update needed', () {
      authProvider.serverVersion = '$atMin.1';
      expect(authProvider.serverUpdateRequired(), false);
    });

    test('null server version — returns false (lenient, no lockout)', () {
      authProvider.serverVersion = null;
      expect(authProvider.serverUpdateRequired(), false);
    });

    test('version override parameter is used instead of stored serverVersion', () {
      authProvider.serverVersion = '99.0'; // would normally not require update
      expect(authProvider.serverUpdateRequired(belowMin), true);
    });

    test('server version with pre-release suffix — still parsed correctly', () {
      authProvider.serverVersion = '$aboveMin.0-beta';
      expect(authProvider.serverUpdateRequired(), false);
    });

    test('server version with Python alpha suffix (e.g. 1.2.3.0a2) — parsed correctly', () {
      authProvider.serverVersion = '$aboveMin.0a2';
      expect(authProvider.serverUpdateRequired(), false);
    });

    test('server version with Python alpha suffix below min — blocked', () {
      authProvider.serverVersion = '${belowMin}.0a2';
      expect(authProvider.serverUpdateRequired(), true);
    });

    test('server version with build metadata suffix — still parsed correctly', () {
      authProvider.serverVersion = '$belowMin.0 (git-abc1234)';
      expect(authProvider.serverUpdateRequired(), true);
    });

    test('completely unparseable server version — returns false (lenient)', () {
      authProvider.serverVersion = 'unknown';
      expect(authProvider.serverUpdateRequired(), false);
    });
  });
}
