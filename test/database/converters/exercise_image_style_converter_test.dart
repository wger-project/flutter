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
import 'package:wger/database/converters/exercise_image_style_converter.dart';
import 'package:wger/features/exercises/models/image.dart';

void main() {
  const converter = ExerciseImageStyleConverter();

  test('maps every wire value to its enum case', () {
    expect(converter.fromSql('1'), ExerciseImageStyle.lineArt);
    expect(converter.fromSql('2'), ExerciseImageStyle.threeD);
    expect(converter.fromSql('3'), ExerciseImageStyle.lowPoly);
    expect(converter.fromSql('4'), ExerciseImageStyle.photo);
    expect(converter.fromSql('5'), ExerciseImageStyle.other);
  });

  test('every enum case survives a round trip', () {
    for (final style in ExerciseImageStyle.values) {
      expect(converter.fromSql(converter.toSql(style)), style);
    }
  });

  test('an unknown wire value throws', () {
    expect(() => converter.fromSql('6'), throwsStateError);
  });
}
