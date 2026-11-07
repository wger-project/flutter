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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/core/uuid.dart';

void main() {
  test('generates lowercase hex in the canonical 8-4-4-4-12 shape', () {
    expect(uuidV4(), matches(RegExp(r'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$')));
  });

  test('sets the version and variant bits of a v4 UUID', () {
    for (var i = 0; i < 200; i++) {
      final parts = uuidV4().split('-');

      expect(parts[2][0], '4', reason: 'version nibble');
      expect('89ab', contains(parts[3][0]), reason: 'RFC 4122 variant');
    }
  });

  test('does not repeat itself', () {
    final seen = {for (var i = 0; i < 1000; i++) uuidV4()};

    expect(seen, hasLength(1000));
  });
}
