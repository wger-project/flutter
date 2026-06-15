/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:wger/models/gallery/image.dart';

List<GalleryImage> getTestImages() {
  return [
    GalleryImage(
      id: 1,
      imagePath: 'gallery/1/01-dashboard.png',
      description: 'A very cool image from the gym',
      date: DateTime(2021, 5, 30),
    ),
    GalleryImage(
      id: 2,
      imagePath: 'gallery/1/02-workout-detail.png',
      description: 'Some description',
      date: DateTime(2021, 4, 20),
    ),
    GalleryImage(
      id: 3,
      imagePath: 'gallery/1/05-nutritional-plan.png',
      description: '1 22 333 4444',
      date: DateTime(2021, 5, 30),
    ),
    GalleryImage(
      id: 4,
      imagePath: 'gallery/1/06-weight.png',
      description: '',
      date: DateTime(2021, 2, 22),
    ),
  ];
}
