// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExerciseAliasSubmissionApi _$ExerciseAliasSubmissionApiFromJson(
  Map<String, dynamic> json,
) => _ExerciseAliasSubmissionApi(alias: json['alias'] as String);

Map<String, dynamic> _$ExerciseAliasSubmissionApiToJson(
  _ExerciseAliasSubmissionApi instance,
) => <String, dynamic>{'alias': instance.alias};

_ExerciseCommentSubmissionApi _$ExerciseCommentSubmissionApiFromJson(
  Map<String, dynamic> json,
) => _ExerciseCommentSubmissionApi(alias: json['alias'] as String);

Map<String, dynamic> _$ExerciseCommentSubmissionApiToJson(
  _ExerciseCommentSubmissionApi instance,
) => <String, dynamic>{'alias': instance.alias};

_ExerciseTranslationSubmissionApi _$ExerciseTranslationSubmissionApiFromJson(
  Map<String, dynamic> json,
) => _ExerciseTranslationSubmissionApi(
  name: json['name'] as String,
  description: json['description'] as String,
  language: (json['language'] as num).toInt(),
  author: json['license_author'] as String,
  aliases:
      (json['aliases'] as List<dynamic>?)
          ?.map(
            (e) =>
                ExerciseAliasSubmissionApi.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map(
            (e) => ExerciseCommentSubmissionApi.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$ExerciseTranslationSubmissionApiToJson(
  _ExerciseTranslationSubmissionApi instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'language': instance.language,
  'license_author': instance.author,
  'aliases': instance.aliases,
  'comments': instance.comments,
};

_ExerciseSubmissionApi _$ExerciseSubmissionApiFromJson(
  Map<String, dynamic> json,
) => _ExerciseSubmissionApi(
  category: (json['category'] as num).toInt(),
  muscles: (json['muscles'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  musclesSecondary: (json['muscles_secondary'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  equipment: (json['equipment'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  author: json['license_author'] as String,
  variation: (json['variation'] as num?)?.toInt(),
  variationConnectTo: (json['variations_connect_to'] as num?)?.toInt(),
  translations: (json['translations'] as List<dynamic>)
      .map(
        (e) => ExerciseTranslationSubmissionApi.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
);

Map<String, dynamic> _$ExerciseSubmissionApiToJson(
  _ExerciseSubmissionApi instance,
) => <String, dynamic>{
  'category': instance.category,
  'muscles': instance.muscles,
  'muscles_secondary': instance.musclesSecondary,
  'equipment': instance.equipment,
  'license_author': instance.author,
  'variation': instance.variation,
  'variations_connect_to': instance.variationConnectTo,
  'translations': instance.translations,
};
