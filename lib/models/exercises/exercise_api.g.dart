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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExerciseBaseData _$ExerciseBaseDataFromJson(Map<String, dynamic> json) => _ExerciseBaseData(
  id: (json['id'] as num).toInt(),
  uuid: json['uuid'] as String,
  variationId: (json['variations'] as num?)?.toInt() ?? null,
  created: DateTime.parse(json['created'] as String),
  lastUpdate: DateTime.parse(json['last_update'] as String),
  lastUpdateGlobal: DateTime.parse(json['last_update_global'] as String),
  category: ExerciseCategory.fromJson(
    json['category'] as Map<String, dynamic>,
  ),
  muscles: (json['muscles'] as List<dynamic>)
      .map((e) => Muscle.fromJson(e as Map<String, dynamic>))
      .toList(),
  musclesSecondary: (json['muscles_secondary'] as List<dynamic>)
      .map((e) => Muscle.fromJson(e as Map<String, dynamic>))
      .toList(),
  equipment: (json['equipment'] as List<dynamic>)
      .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
      .toList(),
  translations:
      (json['translations'] as List<dynamic>?)
          ?.map((e) => Translation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  images: (json['images'] as List<dynamic>)
      .map((e) => ExerciseImage.fromJson(e as Map<String, dynamic>))
      .toList(),
  videos: (json['videos'] as List<dynamic>)
      .map((e) => Video.fromJson(e as Map<String, dynamic>))
      .toList(),
  authors: (json['author_history'] as List<dynamic>).map((e) => e as String).toList(),
  authorsGlobal: (json['total_authors_history'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ExerciseBaseDataToJson(_ExerciseBaseData instance) => <String, dynamic>{
  'id': instance.id,
  'uuid': instance.uuid,
  'variations': instance.variationId,
  'created': instance.created.toIso8601String(),
  'last_update': instance.lastUpdate.toIso8601String(),
  'last_update_global': instance.lastUpdateGlobal.toIso8601String(),
  'category': instance.category,
  'muscles': instance.muscles,
  'muscles_secondary': instance.musclesSecondary,
  'equipment': instance.equipment,
  'translations': instance.translations,
  'images': instance.images,
  'videos': instance.videos,
  'author_history': instance.authors,
  'total_authors_history': instance.authorsGlobal,
};
