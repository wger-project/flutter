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
import 'package:wger/models/trophies/user_trophy_progression.dart';

void main() {
  group('UserTrophyProgression model', () {
    final trophyJson = {
      'id': 1,
      'uuid': '550e8400-e29b-41d4-a716-446655440000',
      'name': 'First Steps',
      'description': 'Awarded for the first workout',
      'image': 'https://example.org/trophy.png',
      'trophy_type': 'count',
      'is_hidden': false,
      'is_progressive': true,
    };

    final trophyProgressionJson = {
      'trophy': trophyJson,
      'is_earned': false,
      'earned_at': '2020-01-02T15:04:05Z',
      'progress': 42.5,
      'current_value': '12.5',
      'target_value': '100',
      'progress_display': '12.5/100',
    };

    test('fromJson creates valid UserTrophyProgression instance', () {
      final utp = UserTrophyProgression.fromJson(trophyProgressionJson);

      expect(utp.trophy.id, 1);
      expect(utp.trophy.uuid, '550e8400-e29b-41d4-a716-446655440000');
      expect(utp.isEarned, isFalse);

      final expectedEarnedAt = DateTime.parse('2020-01-02T15:04:05Z').toLocal();
      expect(utp.earnedAt, expectedEarnedAt);

      expect(utp.progress, 42.5);
      expect(utp.currentValue, 12.5);
      expect(utp.targetValue, 100);
      expect(utp.progressDisplay, '12.5/100');
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

      final earnedAt = DateTime.parse('2020-01-02T15:04:05Z').toLocal();

      final utp = UserTrophyProgression(
        trophy: trophy,
        isEarned: true,
        earnedAt: earnedAt,
        progress: 75,
        currentValue: 75,
        targetValue: 100,
        progressDisplay: '75/100',
      );

      final json = utp.toJson();

      expect(json['trophy'], same(trophy));
      expect(json['is_earned'], true);
      expect(json['earned_at'], earnedAt.toIso8601String());
      expect(json['progress'], 75);
      expect(json['current_value'], 75);
      expect(json['target_value'], 100);
      expect(json['progress_display'], '75/100');
    });
  });
}
