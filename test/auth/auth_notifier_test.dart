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
import 'package:version/version.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/providers/auth_notifier.dart';

void main() {
  group('min server version check', () {
    final minVersion = Version.parse(MIN_SERVER_VERSION);
    final aboveMin = Version(minVersion.major, minVersion.minor + 1, 0).toString();
    const atMin = MIN_SERVER_VERSION;
    final belowMin = Version(minVersion.major, minVersion.minor - 1, 0).toString();

    test('server version greater than min — no update needed', () {
      expect(serverUpdateRequired(aboveMin), false);
    });

    test('server version equal to min — no update needed', () {
      expect(serverUpdateRequired(atMin), false);
    });

    test('server version less than min — update needed', () {
      expect(serverUpdateRequired(belowMin), true);
    });

    test('server version with patch component less than min — update needed', () {
      expect(serverUpdateRequired('$belowMin.9'), true);
    });

    test('server version with patch component greater than min — no update needed', () {
      expect(serverUpdateRequired('$atMin.1'), false);
    });

    test('null server version — returns false (lenient, no lockout)', () {
      expect(serverUpdateRequired(null), false);
    });

    test('server version with pre-release suffix — still parsed correctly', () {
      expect(serverUpdateRequired('$aboveMin.0-beta'), false);
    });

    test('server version with Python alpha suffix (e.g. 1.2.3.0a2) — parsed correctly', () {
      expect(serverUpdateRequired('$aboveMin.0a2'), false);
    });

    test('server version with Python alpha suffix below min — blocked', () {
      expect(serverUpdateRequired('$belowMin.0a2'), true);
    });

    test('server version with build metadata suffix — still parsed correctly', () {
      expect(serverUpdateRequired('$belowMin.0 (git-abc1234)'), true);
    });

    test('completely unparseable server version — returns false (lenient)', () {
      expect(serverUpdateRequired('unknown'), false);
    });
  });
}
