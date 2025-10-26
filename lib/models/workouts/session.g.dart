/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
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

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'routine',
      'day',
      'date',
      'impression',
      'time_start',
      'time_end',
    ],
  );
  return WorkoutSession(
    id: json['id'] as String?,
    dayId: (json['day'] as num?)?.toInt(),
    routineId: (json['routine'] as num?)?.toInt(),
    impression: json['impression'] == null ? 2 : int.parse(json['impression'] as String),
    notes: json['notes'] as String? ?? '',
    timeStart: stringToTimeNull(json['time_start'] as String?),
    timeEnd: stringToTimeNull(json['time_end'] as String?),
    logs:
        (json['logs'] as List<dynamic>?)
            ?.map((e) => Log.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  );
}

Map<String, dynamic> _$WorkoutSessionToJson(WorkoutSession instance) => <String, dynamic>{
  'id': instance.id,
  'routine': instance.routineId,
  'day': instance.dayId,
  'date': dateToYYYYMMDD(instance.date),
  'impression': numToString(instance.impression),
  'notes': instance.notes,
  'time_start': timeToString(instance.timeStart),
  'time_end': timeToString(instance.timeEnd),
};
