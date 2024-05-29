// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'comment'],
  );
  return Comment(
    id: (json['id'] as num).toInt(),
    exerciseId: (json['exercise'] as num).toInt(),
    comment: json['comment'] as String,
  );
}

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'exercise': instance.exerciseId,
      'comment': instance.comment,
    };
