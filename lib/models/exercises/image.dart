import 'package:json_annotation/json_annotation.dart';

part 'image.g.dart';

@JsonSerializable()
class ExerciseImage {
  @JsonKey(required: true, name: 'image')
  final String url;

  @JsonKey(name: 'is_main', defaultValue: false)
  final bool isMain;

  ExerciseImage({
    this.url,
    this.isMain,
  });

  // Boilerplate
  factory ExerciseImage.fromJson(Map<String, dynamic> json) => _$ExerciseImageFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseImageToJson(this);
}
