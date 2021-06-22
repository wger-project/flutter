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

part 'image.g.dart';

@JsonSerializable()
class ExerciseImage {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String uuid;

  @JsonKey(required: true, name: 'exercise_base')
  final int exerciseBaseId;

  @JsonKey(required: true, name: 'image')
  final String url;

  @JsonKey(name: 'is_main', defaultValue: false)
  final bool isMain;

  ExerciseImage({
    required this.id,
    required this.uuid,
    required this.exerciseBaseId,
    required this.url,
    required this.isMain,
  });

  // Boilerplate
  factory ExerciseImage.fromJson(Map<String, dynamic> json) => _$ExerciseImageFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseImageToJson(this);
}
