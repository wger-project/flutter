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

part of 'user_trophy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTrophy _$UserTrophyFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'trophy',
      'earned_at',
      'progress',
      'is_notified',
    ],
  );
  return UserTrophy(
    id: (json['id'] as num).toInt(),
    trophy: Trophy.fromJson(json['trophy'] as Map<String, dynamic>),
    earnedAt: utcIso8601ToLocalDate(json['earned_at'] as String),
    progress: json['progress'] as num,
    isNotified: json['is_notified'] as bool,
  );
}

Map<String, dynamic> _$UserTrophyToJson(UserTrophy instance) => <String, dynamic>{
  'id': instance.id,
  'trophy': instance.trophy,
  'earned_at': instance.earnedAt.toIso8601String(),
  'progress': instance.progress,
  'is_notified': instance.isNotified,
};
