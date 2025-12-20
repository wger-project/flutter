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

import 'package:wger/models/trophies/trophy.dart';
import 'package:wger/models/trophies/user_trophy.dart';
import 'package:wger/models/trophies/user_trophy_progression.dart';

List<Trophy> getTestTrophies() {
  return [
    Trophy(
      id: 1,
      uuid: '31a71d9a-bf26-4f18-b82f-afefe6f50df2',
      name: 'New Year, New Me',
      description: 'Work out on January 1st',
      image: 'https://example.com/5362e55b-eaf1-4e34-9ef8-661538a3bdd9.png',
      type: TrophyType.date,
      isHidden: false,
      isProgressive: false,
    ),
    Trophy(
      id: 2,
      uuid: 'b605b6a1-953d-41fb-87c9-a2f88b5f5907',
      name: 'Unstoppable',
      description: 'Maintain a 30-day workout streak',
      image: 'https://example.com/b605b6a1-953d-41fb-87c9-a2f88b5f5907.png',
      type: TrophyType.sequence,
      isHidden: false,
      isProgressive: true,
    ),
  ];
}

List<UserTrophyProgression> getUserTrophyProgression() {
  final trophies = getTestTrophies();

  return [
    UserTrophyProgression(
      trophy: trophies[0],
      progress: 100,
      isEarned: true,
      earnedAt: DateTime(2025, 12, 20),
      currentValue: null,
      targetValue: null,
      progressDisplay: null,
    ),
  ];
}

List<UserTrophy> getUserTrophies() {
  final trophies = getTestTrophies();

  return [
    UserTrophy(
      id: 4,
      earnedAt: DateTime(2025, 12, 20),
      isNotified: true,
      progress: 100,
      trophy: trophies[0],
    ),
  ];
}
