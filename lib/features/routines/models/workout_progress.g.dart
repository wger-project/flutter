// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutProgress _$WorkoutProgressFromJson(Map<String, dynamic> json) => _WorkoutProgress(
  dayId: (json['dayId'] as num).toInt(),
  iteration: (json['iteration'] as num).toInt(),
  currentPageKey: json['currentPageKey'] as String,
  workoutStart: DateTime.parse(json['workoutStart'] as String),
  validUntil: DateTime.parse(json['validUntil'] as String),
  pages:
      (json['pages'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          StoredPageProgress.fromJson(e as Map<String, dynamic>),
        ),
      ) ??
      const {},
);

Map<String, dynamic> _$WorkoutProgressToJson(_WorkoutProgress instance) => <String, dynamic>{
  'dayId': instance.dayId,
  'iteration': instance.iteration,
  'currentPageKey': instance.currentPageKey,
  'workoutStart': instance.workoutStart.toIso8601String(),
  'validUntil': instance.validUntil.toIso8601String(),
  'pages': instance.pages,
};

_StoredPageProgress _$StoredPageProgressFromJson(Map<String, dynamic> json) => _StoredPageProgress(
  done: json['done'] as bool? ?? false,
  logId: json['logId'] as String?,
  timerStartedAt: json['timerStartedAt'] == null
      ? null
      : DateTime.parse(json['timerStartedAt'] as String),
);

Map<String, dynamic> _$StoredPageProgressToJson(_StoredPageProgress instance) => <String, dynamic>{
  'done': instance.done,
  'logId': instance.logId,
  'timerStartedAt': instance.timerStartedAt?.toIso8601String(),
};
