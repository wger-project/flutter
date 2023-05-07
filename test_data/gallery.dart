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

import 'package:wger/models/gallery/image.dart' as gallery;

List<gallery.Image> getTestImages() {
  return [
    gallery.Image(
      id: 1,
      url:
          'https://raw.githubusercontent.com/wger-project/flutter/master/fastlane/metadata/android/en-US/images/phoneScreenshots/02%20-%20workout%20detail.png',
      description: 'A very cool image from the gym',
      date: DateTime(2021, 5, 30),
    ),
    gallery.Image(
      id: 2,
      url:
          'https://raw.githubusercontent.com/wger-project/flutter/master/fastlane/metadata/android/en-US/images/phoneScreenshots/01%20-%20dashboard.png',
      description: 'Some description',
      date: DateTime(2021, 4, 20),
    ),
    gallery.Image(
      id: 3,
      url:
          'https://raw.githubusercontent.com/wger-project/flutter/master/fastlane/metadata/android/en-US/images/phoneScreenshots/05%20-%20nutritional%20plan.png',
      description: '1 22 333 4444',
      date: DateTime(2021, 5, 30),
    ),
    gallery.Image(
      id: 4,
      url:
          'https://raw.githubusercontent.com/wger-project/flutter/master/fastlane/metadata/android/en-US/images/phoneScreenshots/06%20-%20weight.png',
      description: '',
      date: DateTime(2021, 2, 22),
    )
  ];
}
