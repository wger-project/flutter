import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  Category({
    this.id,
    this.name,
  });

  @override
  String toString() {
    return 'Category $id';
  }

  // Boilerplate
  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
