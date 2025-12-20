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
