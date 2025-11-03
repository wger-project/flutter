/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

class Video {
  final int id;
  final String uuid;
  final String url;

  Uri get uri => Uri.parse(url);

  final int exerciseId;
  final int size;
  final num duration;
  final int width;
  final int height;
  final String codec;
  final String codecLong;
  final int licenseId;
  final String? licenseAuthor;

  const Video({
    required this.id,
    required this.uuid,
    required this.exerciseId,
    required this.size,
    required this.url,
    required this.duration,
    required this.width,
    required this.height,
    required this.codec,
    required this.codecLong,
    required this.licenseId,
    required this.licenseAuthor,
  });
}
