import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/exercises/category.dart' as cat;
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/image.dart' as img;
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
  final cat.Category category;

  @JsonKey(required: false)
  List<Muscle> muscles = [];

  @JsonKey(required: false)
  List<Muscle> musclesSecondary = [];

  @JsonKey(required: false)
  List<Equipment> equipment = [];

  @JsonKey(required: false)
  List<img.Image> images = [];

  @JsonKey(required: false)
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

  img.Image get getMainImage {
    return images.firstWhere((image) => image.isMain);
  }

  // Boilerplate
  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}
