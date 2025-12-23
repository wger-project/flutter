/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2025 wger Team
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
import 'package:wger/models/trophies/trophy.dart';

void main() {
  group('Trophy model', () {
    final sampleJson = {
      'id': 1,
      'uuid': '550e8400-e29b-41d4-a716-446655440000',
      'name': 'First Steps',
      'description': 'Awarded for the first workout',
      'image': 'https://example.org/trophy.png',
      'trophy_type': 'count',
      'is_hidden': false,
      'is_progressive': true,
    };

    test('fromJson creates valid Trophy instance', () {
      final trophy = Trophy.fromJson(sampleJson);

      expect(trophy.id, 1);
      expect(trophy.uuid, '550e8400-e29b-41d4-a716-446655440000');
      expect(trophy.name, 'First Steps');
      expect(trophy.description, 'Awarded for the first workout');
      expect(trophy.image, 'https://example.org/trophy.png');
      expect(trophy.type, TrophyType.count);
      expect(trophy.isHidden, isFalse);
      expect(trophy.isProgressive, isTrue);
    });

    test('toJson returns expected map', () {
      final trophy = Trophy(
        id: 2,
        uuid: '00000000-0000-0000-0000-000000000000',
        name: 'Progressor',
        description: 'Progressive trophy',
        image: 'https://example.org/prog.png',
        type: TrophyType.time,
        isHidden: true,
        isProgressive: false,
      );

      final json = trophy.toJson();

      expect(json['id'], 2);
      expect(json['uuid'], '00000000-0000-0000-0000-000000000000');
      expect(json['name'], 'Progressor');
      expect(json['description'], 'Progressive trophy');
      expect(json['image'], 'https://example.org/prog.png');
      expect(json['trophy_type'], 'time');
      expect(json['is_hidden'], true);
      expect(json['is_progressive'], false);
    });
  });
}
