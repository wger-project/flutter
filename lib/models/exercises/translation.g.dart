// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Translation _$TranslationFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'uuid',
      'language',
      'created',
      'exercise_base',
      'name',
      'description'
    ],
  );
  return Translation(
    id: (json['id'] as num?)?.toInt(),
    uuid: json['uuid'] as String?,
    created: json['created'] == null
        ? null
        : DateTime.parse(json['created'] as String),
    name: json['name'] as String,
    description: json['description'] as String,
    exerciseId: (json['exercise_base'] as num?)?.toInt(),
  )
    ..languageId = (json['language'] as num).toInt()
    ..notes = (json['notes'] as List<dynamic>)
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList()
    ..aliases = (json['aliases'] as List<dynamic>)
        .map((e) => Alias.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$TranslationToJson(Translation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'language': instance.languageId,
      'created': instance.created?.toIso8601String(),
      'exercise_base': instance.exerciseId,
      'name': instance.name,
      'description': instance.description,
    };
