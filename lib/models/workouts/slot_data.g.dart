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

part of 'slot_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlotData _$SlotDataFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['comment', 'is_superset', 'exercises', 'sets'],
  );
  return SlotData(
    comment: json['comment'] as String? ?? '',
    isSuperset: json['is_superset'] as bool? ?? false,
    exerciseIds:
        (json['exercises'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
    setConfigs:
        (json['sets'] as List<dynamic>?)
            ?.map((e) => SetConfigData.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
  );
}

Map<String, dynamic> _$SlotDataToJson(SlotData instance) => <String, dynamic>{
  'comment': instance.comment,
  'is_superset': instance.isSuperset,
  'exercises': instance.exerciseIds,
  'sets': instance.setConfigs,
};
