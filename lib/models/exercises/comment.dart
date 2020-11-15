import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String comment;

  Comment({
    this.id,
    this.comment,
  });

  // Boilerplate
  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
