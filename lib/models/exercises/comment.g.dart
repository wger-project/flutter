// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'exercise', 'comment'],
  );
  return Comment(
    id: json['id'] as int,
    exerciseId: json['exercise'] as int,
    comment: json['comment'] as String,
  );
}

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'exercise': instance.exerciseId,
      'comment': instance.comment,
    };
