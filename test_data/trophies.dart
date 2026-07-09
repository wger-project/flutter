/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:wger/features/trophies/models/trophy.dart';
import 'package:wger/features/trophies/models/user_trophy.dart';

const _trophyImageBase =
    'https://raw.githubusercontent.com/wger-project/wger/master/wger/trophies/static/trophies';

/// Sample earned (non-PR) trophies. Images point at the real trophy artwork in
/// the wger repo, the WgerImage widget falls back to the trophy icon if a URL
/// can't be loaded.
List<UserTrophy> getScreenshotUserTrophies() {
  Trophy trophy(int id, String name, String description, TrophyType type, String imagePath) =>
      Trophy(
        id: id,
        uuid: 'screenshot-trophy-$id',
        name: name,
        description: description,
        image: '$_trophyImageBase/$imagePath',
        type: type,
        isHidden: false,
        isProgressive: false,
      );

  return [
    UserTrophy(
      id: 1,
      trophy: trophy(
        1,
        'First workout',
        'Completed your very first workout session',
        TrophyType.count,
        'count/9f1c7c7e-3b2a-4b6f-9b5f-1c3e2d4f5a60.png',
      ),
      earnedAt: DateTime(2026, 1, 5),
      progress: 100,
      isNotified: true,
    ),
    UserTrophy(
      id: 2,
      trophy: trophy(
        2,
        '5000 kg lifted',
        'Lifted a whole elefant',
        TrophyType.volume,
        'volume/5353989b-adc0-481b-a9bc-64365a9179e8.png',
      ),
      earnedAt: DateTime(2026, 2, 14),
      progress: 100,
      isNotified: true,
    ),
    UserTrophy(
      id: 3,
      trophy: trophy(
        3,
        '7 day streak',
        'Trained every day for a full week',
        TrophyType.sequence,
        'sequence/b605b6a1-953d-41fb-87c9-a2f88b5f5907.png',
      ),
      earnedAt: DateTime(2026, 3, 1),
      progress: 100,
      isNotified: true,
    ),
  ];
}
