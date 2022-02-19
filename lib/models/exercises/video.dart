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

import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/json.dart';

part 'video.g.dart';

@JsonSerializable()
class Video {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String uuid;

  @JsonKey(name: 'video', required: true)
  final String url;

  @JsonKey(name: 'exercise_base', required: true)
  final int base;

  @JsonKey(required: true)
  final int size;

  @JsonKey(required: true, fromJson: stringToNum, toJson: numToString)
  final num duration;

  @JsonKey(required: true)
  final int width;

  @JsonKey(required: true)
  final int height;

  @JsonKey(required: true)
  final String codec;

  @JsonKey(name: 'codec_long', required: true)
  final String codecLong;

  @JsonKey(required: true)
  final int license;

  @JsonKey(name: 'license_author', required: true)
  final String? licenseAuthor;

  const Video({
    required this.id,
    required this.uuid,
    required this.base,
    required this.size,
    required this.url,
    required this.duration,
    required this.width,
    required this.height,
    required this.codec,
    required this.codecLong,
    required this.license,
    required this.licenseAuthor,
  });

  // Boilerplate
  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
  Map<String, dynamic> toJson() => _$VideoToJson(this);
}
