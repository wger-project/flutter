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

part of 'log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Log _$LogFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'exercise',
      'routine',
      'session',
      'iteration',
      'slot_entry',
      'repetitions',
      'repetitions_target',
      'repetitions_unit',
      'weight',
      'weight_target',
      'weight_unit',
      'date',
    ],
  );
  return Log(
    id: idFromJson(json['id']),
    exerciseId: (json['exercise'] as num).toInt(),
    iteration: (json['iteration'] as num?)?.toInt(),
    slotEntryId: (json['slot_entry'] as num?)?.toInt(),
    routineId: (json['routine'] as num).toInt(),
    repetitions: stringToNum(json['repetitions'] as String?),
    repetitionsTarget: stringToNum(json['repetitions_target'] as String?),
    repetitionsUnitId: (json['repetitions_unit'] as num?)?.toInt() ?? REP_UNIT_REPETITIONS_ID,
    rir: stringToNum(json['rir'] as String?),
    rirTarget: stringToNum(json['rir_target'] as String?),
    weight: stringToNum(json['weight'] as String?),
    weightTarget: stringToNum(json['weight_target'] as String?),
    weightUnitId: (json['weight_unit'] as num?)?.toInt() ?? WEIGHT_UNIT_KG,
    date: DateTime.parse(json['date'] as String),
  )..sessionId = (json['session'] as num?)?.toInt();
}

Map<String, dynamic> _$LogToJson(Log instance) => <String, dynamic>{
  'id': instance.id,
  'exercise': instance.exerciseId,
  'routine': instance.routineId,
  'session': instance.sessionId,
  'iteration': instance.iteration,
  'slot_entry': instance.slotEntryId,
  'rir': instance.rir,
  'rir_target': instance.rirTarget,
  'repetitions': instance.repetitions,
  'repetitions_target': instance.repetitionsTarget,
  'repetitions_unit': instance.repetitionsUnitId,
  'weight': numToString(instance.weight),
  'weight_target': numToString(instance.weightTarget),
  'weight_unit': instance.weightUnitId,
  'date': dateToUtcIso8601(instance.date),
};
