// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'comment']);
  return Comment(
    id: (json['id'] as num).toInt(),
    translationId: (json['translation'] as num).toInt(),
    comment: json['comment'] as String,
  );
}

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'translation': instance.translationId,
  'comment': instance.comment,
};
