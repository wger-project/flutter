/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2025 wger Team
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

part of 'trophy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trophy _$TrophyFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'uuid',
      'name',
      'description',
      'image',
      'trophy_type',
      'is_hidden',
      'is_progressive',
    ],
  );
  return Trophy(
    id: (json['id'] as num).toInt(),
    uuid: json['uuid'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    image: json['image'] as String,
    type: $enumDecode(_$TrophyTypeEnumMap, json['trophy_type']),
    isHidden: json['is_hidden'] as bool,
    isProgressive: json['is_progressive'] as bool,
  );
}

Map<String, dynamic> _$TrophyToJson(Trophy instance) => <String, dynamic>{
  'id': instance.id,
  'uuid': instance.uuid,
  'name': instance.name,
  'description': instance.description,
  'image': instance.image,
  'trophy_type': _$TrophyTypeEnumMap[instance.type]!,
  'is_hidden': instance.isHidden,
  'is_progressive': instance.isProgressive,
};

const _$TrophyTypeEnumMap = {
  TrophyType.time: 'time',
  TrophyType.volume: 'volume',
  TrophyType.count: 'count',
  TrophyType.sequence: 'sequence',
  TrophyType.date: 'date',
  TrophyType.pr: 'pr',
  TrophyType.other: 'other',
};
