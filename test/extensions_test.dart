/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/helpers/misc.dart';

void main() {
  test('Test the TimeOfDayExtension', () {
    const time1 = TimeOfDay(hour: 00, minute: 00);
    const time2 = TimeOfDay(hour: 23, minute: 59);

    expect(time2.toMinutes(), 23 * 60 + 59);
    expect(time1.isAfter(time2), false);
    expect(time1.isBefore(time2), true);
    expect(time2.isAfter(time1), true);
    expect(time2.isBefore(time1), false);
    expect(time1.isAfter(time1), false);
    expect(time2.isBefore(time2), false);
  });
}
