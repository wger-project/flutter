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
import 'package:wger/database/converters/utc_datetime_converter.dart';

// The assertions compare instants and the isUtc flag, never wall-clock
// components, so they hold in every time zone.
void main() {
  const converter = UtcDateTimeConverter();

  group('toSql', () {
    test('converts a local value to UTC without moving the instant', () {
      final local = DateTime(2026, 6, 15, 14, 30);

      final stored = converter.toSql(local);

      expect(stored.isUtc, isTrue);
      expect(stored.isAtSameMomentAs(local), isTrue);
    });

    test('leaves a value that is already UTC untouched', () {
      final utc = DateTime.utc(2026, 6, 15, 14, 30);

      expect(converter.toSql(utc), utc);
    });
  });

  group('fromSql', () {
    test('returns the stored instant in the local zone', () {
      final stored = DateTime.utc(2026, 6, 15, 12);

      final read = converter.fromSql(stored);

      expect(read.isUtc, isFalse);
      expect(read.isAtSameMomentAs(stored), isTrue);
    });
  });

  test('a round trip preserves the instant', () {
    final local = DateTime(2026, 1, 31, 23, 59, 59);

    expect(converter.fromSql(converter.toSql(local)), local);
  });
}
