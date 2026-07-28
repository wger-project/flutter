// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_trophy_progression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTrophyProgression _$UserTrophyProgressionFromJson(
  Map<String, dynamic> json,
) {
  $checkKeys(
    json,
    requiredKeys: const [
      'trophy',
      'is_earned',
      'earned_at',
      'progress',
      'current_value',
      'target_value',
      'progress_display',
    ],
  );
  return UserTrophyProgression(
    trophy: Trophy.fromJson(json['trophy'] as Map<String, dynamic>),
    isEarned: json['is_earned'] as bool,
    earnedAt: utcIso8601ToLocalDateNull(json['earned_at'] as String?),
    progress: json['progress'] as num,
    currentValue: stringToNumNull(json['current_value'] as String?),
    targetValue: stringToNumNull(json['target_value'] as String?),
    progressDisplay: json['progress_display'] as String?,
  );
}

Map<String, dynamic> _$UserTrophyProgressionToJson(
  UserTrophyProgression instance,
) => <String, dynamic>{
  'trophy': instance.trophy,
  'is_earned': instance.isEarned,
  'earned_at': instance.earnedAt?.toIso8601String(),
  'progress': instance.progress,
  'current_value': instance.currentValue,
  'target_value': instance.targetValue,
  'progress_display': instance.progressDisplay,
};
