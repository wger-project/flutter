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
import 'package:wger/database/converters/workout_impression_converter.dart';
import 'package:wger/features/routines/models/session.dart';

void main() {
  const converter = WorkoutImpressionConverter();

  test('maps every wire value to its enum case', () {
    expect(converter.fromSql('1'), WorkoutImpression.bad);
    expect(converter.fromSql('2'), WorkoutImpression.neutral);
    expect(converter.fromSql('3'), WorkoutImpression.good);
  });

  test('every enum case survives a round trip', () {
    for (final impression in WorkoutImpression.values) {
      expect(converter.fromSql(converter.toSql(impression)), impression);
    }
  });

  test('an unknown wire value throws', () {
    // This sits on the read path of every session, so a new server-side
    // choice surfaces as a StateError rather than a silent default
    expect(() => converter.fromSql('4'), throwsStateError);
  });
}
