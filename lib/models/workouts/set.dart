import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/setting.dart';

part 'set.g.dart';

@JsonSerializable()
class Set {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final int sets;

  @JsonKey(required: true)
  final int order;

  @JsonKey(required: true)
  List<Exercise> exercises = [];

  @JsonKey(required: false)
  List<Setting> settings = [];

  Set({
    this.id,
    this.sets,
    this.order,
    this.exercises,
    this.settings,
  });

  // Boilerplate
  factory Set.fromJson(Map<String, dynamic> json) => _$SetFromJson(json);
  Map<String, dynamic> toJson() => _$SetToJson(this);
}
