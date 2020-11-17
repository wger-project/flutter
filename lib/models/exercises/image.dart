import 'package:json_annotation/json_annotation.dart';

part 'image.g.dart';

@JsonSerializable()
class Image {
  @JsonKey(required: true, name: 'image')
  final String url;

  @JsonKey(name: 'is_main', defaultValue: false)
  final bool isMain;

  Image({
    this.url,
    this.isMain,
  });

  // Boilerplate
  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
  Map<String, dynamic> toJson() => _$ImageToJson(this);
}
