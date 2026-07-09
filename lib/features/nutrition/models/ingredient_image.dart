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
import 'package:json_annotation/json_annotation.dart';

part 'ingredient_image.g.dart';

@JsonSerializable()
class IngredientImage {
  @JsonKey(required: true)
  final int id;

  /// Barcode of the product
  @JsonKey(required: true)
  final String uuid;

  /// Name of the product
  @JsonKey(required: true, name: 'ingredient_id')
  final int ingredientId;

  /// Relative path of the image on the server (Django `ImageField`)
  @JsonKey(required: true)
  final String image;

  /// Size in bytes
  @JsonKey(required: true)
  final int size;

  /// Image width in pixels
  @JsonKey(required: true)
  final int width;

  /// Image height in pixels
  @JsonKey(required: true)
  final int height;

  /// Server creation timestamp
  @JsonKey(required: true)
  final DateTime created;

  /// Server last-modification timestamp
  @JsonKey(required: true, name: 'last_update')
  final DateTime lastUpdate;

  // License information

  /// License ID
  @JsonKey(required: true, name: 'license')
  final int licenseId;

  /// Author(s), may be null on the server (`TextField(null=True)`)
  @JsonKey(required: true, name: 'license_author')
  final String? author;

  /// Author profile, if available
  @JsonKey(required: true, name: 'license_author_url')
  final String authorUrl;

  /// The title of the image
  @JsonKey(required: true, name: 'license_title')
  final String title;

  /// The URL of the original image
  @JsonKey(required: true, name: 'license_object_url')
  final String objectUrl;

  /// The URL of the original image if this is a derivative object
  @JsonKey(required: true, name: 'license_derivative_source_url')
  final String derivativeSourceUrl;

  const IngredientImage({
    required this.id,
    required this.uuid,
    required this.ingredientId,
    required this.image,
    required this.size,
    required this.width,
    required this.height,
    required this.created,
    required this.lastUpdate,
    required this.licenseId,
    required this.author,
    required this.authorUrl,
    required this.title,
    required this.objectUrl,
    required this.derivativeSourceUrl,
  });

  // Boilerplate
  factory IngredientImage.fromJson(Map<String, dynamic> json) => _$IngredientImageFromJson(json);

  Map<String, dynamic> toJson() => _$IngredientImageToJson(this);
}
