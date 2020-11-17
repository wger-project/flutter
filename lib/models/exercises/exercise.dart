import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/muscle.dart';

part 'exercise.g.dart';

@JsonSerializable(explicitToJson: true)
class Exercise {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String uuid;

  @JsonKey(required: true, name: 'creation_date')
  final DateTime creationDate;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final String description;

  @JsonKey(required: true)
  final ExerciseCategory category;

  @JsonKey(required: true)
  List<Muscle> muscles = [];

  @JsonKey(required: true, name: 'muscles_secondary')
  List<Muscle> musclesSecondary = [];

  @JsonKey(required: true)
  List<Equipment> equipment = [];

  @JsonKey(required: true)
  List<ExerciseImage> images = [];

  @JsonKey(required: true, name: 'comments')
  List<Comment> tips = [];

  Exercise({
    this.id,
    this.uuid,
    this.creationDate,
    this.name,
    this.description,
    this.category,
    this.muscles,
    this.musclesSecondary,
    this.equipment,
    this.images,
    this.tips,
  });

  ExerciseImage get getMainImage {
    return images.firstWhere((image) => image.isMain);
  }

  // Boilerplate
  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}
