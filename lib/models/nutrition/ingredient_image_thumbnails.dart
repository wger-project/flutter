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

part 'ingredient_image_thumbnails.g.dart';

@JsonSerializable()
class IngredientImageThumbnails {
  @JsonKey(required: true)
  final String small;

  @JsonKey(required: true, name: 'small_cropped')
  final String smallCropped;

  @JsonKey(required: true)
  final String medium;

  @JsonKey(required: true, name: 'medium_cropped')
  final String mediumCropped;

  @JsonKey(required: true)
  final String large;

  @JsonKey(required: true, name: 'large_cropped')
  final String largeCropped;

  const IngredientImageThumbnails({
    required this.small,
    required this.smallCropped,
    required this.medium,
    required this.mediumCropped,
    required this.large,
    required this.largeCropped,
  });

  // Boilerplate
  factory IngredientImageThumbnails.fromJson(Map<String, dynamic> json) =>
      _$IngredientImageThumbnailsFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientImageThumbnailsToJson(this);
}
