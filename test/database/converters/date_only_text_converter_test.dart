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
import 'package:wger/database/converters/date_only_text_converter.dart';

void main() {
  const converter = DateOnlyTextConverter();

  group('toSql', () {
    test('writes the calendar day zero-padded', () {
      expect(converter.toSql(DateTime(2026, 3, 7)), '2026-03-07');
    });

    test('drops the time of day', () {
      expect(converter.toSql(DateTime(2026, 3, 7, 23, 59, 59)), '2026-03-07');
    });

    test('writes the day the value represents in its own zone', () {
      expect(converter.toSql(DateTime.utc(2026, 3, 7)), '2026-03-07');
    });
  });

  group('fromSql', () {
    test('parses a bare date into UTC midnight', () {
      final read = converter.fromSql('2026-03-07');

      expect(read, DateTime.utc(2026, 3, 7));
      expect(read.isUtc, isTrue);
    });

    test('takes the leading day of a legacy full timestamp', () {
      // Rows written before this converter carry a full ISO timestamp
      expect(converter.fromSql('2026-03-07T00:00:00.000Z'), DateTime.utc(2026, 3, 7));
    });
  });

  test('a locally written day and the same day synced back compare equal', () {
    // The regression this converter exists for: a `.equals()` lookup on a date
    // column has to match whether the row was written here or came from the
    // server, which sends a bare `YYYY-MM-DD`
    final writtenLocally = converter.toSql(DateTime(2026, 3, 7, 18, 45));
    final syncedBack = converter.toSql(converter.fromSql('2026-03-07'));

    expect(writtenLocally, syncedBack);
  });

  test('a round trip keeps the calendar day', () {
    final read = converter.fromSql(converter.toSql(DateTime(2026, 12, 31, 22)));

    expect([read.year, read.month, read.day], [2026, 12, 31]);
  });
}
