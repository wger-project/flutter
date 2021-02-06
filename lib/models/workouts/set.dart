import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/setting.dart';

part 'set.g.dart';

@JsonSerializable()
class Set {
  static const DEFAULT_NR_SETS = 4;

  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  int sets;

  @JsonKey(required: false, name: 'exerciseday')
  int day;

  @JsonKey(required: true)
  int order;

  //@JsonKey(required: true)
  List<Exercise> exercisesObj = [];

  @JsonKey(required: true, name: 'exercises')
  List<int> exercisesIds = [];

  @JsonKey(required: false)
  List<Setting> settings = [];

  Set({
    this.id,
    sets,
    this.day,
    this.order,
    exercises,
    settings,
  }) {
    this.sets = sets ?? DEFAULT_NR_SETS;
    this.exercisesObj = exercises ?? [];
    this.exercisesIds = exercisesObj.map((e) => e.id).toList();
    this.settings = settings ?? [];
  }

  void addExercise(Exercise exercise) {
    exercisesObj.add(exercise);
    exercisesIds.add(exercise.id);
  }

  void removeExercise(Exercise exercise) {
    exercisesObj.removeWhere((e) => e.id == exercise.id);
    exercisesIds.removeWhere((e) => e == exercise.id);
  }

  // Boilerplate
  factory Set.fromJson(Map<String, dynamic> json) => _$SetFromJson(json);
  Map<String, dynamic> toJson() => _$SetToJson(this);
}
