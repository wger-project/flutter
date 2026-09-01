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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/database/converters/time_of_day_converter.dart';

void main() {
  const converter = TimeOfDayConverter();

  test('writes 24 hour format regardless of the device locale', () {
    expect(converter.toSql(const TimeOfDay(hour: 18, minute: 5)), '18:05');
    expect(converter.toSql(const TimeOfDay(hour: 0, minute: 0)), '00:00');
  });

  test('reads a stored time back', () {
    expect(converter.fromSql('18:05'), const TimeOfDay(hour: 18, minute: 5));
  });

  test('a round trip preserves the time', () {
    const time = TimeOfDay(hour: 7, minute: 30);

    expect(converter.fromSql(converter.toSql(time)), time);
  });

  test('reads a stored time that carries seconds', () {
    // Django serializes `TimeField` with seconds
    expect(converter.fromSql('18:05:00'), const TimeOfDay(hour: 18, minute: 5));
  });
}
