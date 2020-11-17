import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class ExerciseCategory {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  ExerciseCategory({
    this.id,
    this.name,
  });

  @override
  String toString() {
    return 'Category $id';
  }

  // Boilerplate
  factory ExerciseCategory.fromJson(Map<String, dynamic> json) => _$ExerciseCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseCategoryToJson(this);
}
