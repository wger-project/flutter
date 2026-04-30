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

class ExerciseImage {
  final int id;
  final String uuid;
  final int exerciseId;

  /// Relative path of the image on the server (Django `ImageField`),
  /// e.g. `exercise-images/91/foo.png`
  final String image;

  final bool isMain;

  const ExerciseImage({
    required this.id,
    required this.uuid,
    required this.exerciseId,
    required this.image,
    required this.isMain,
  });

  @override
  String toString() {
    return 'Image $id: $image';
  }
}
