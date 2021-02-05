import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/setting.dart';

part 'set.g.dart';

@JsonSerializable()
class Set {
  static const DEFAULT_NR_SETS = 4;

  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  int sets;

  @JsonKey(required: false, name: 'exerciseday')
  int day;

  @JsonKey(required: true)
  int order;

  @JsonKey(required: true)
  List<Exercise> exercises = [];

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
    this.exercises = exercises ?? [];
    this.settings = settings ?? [];
  }

  // Boilerplate
  factory Set.fromJson(Map<String, dynamic> json) => _$SetFromJson(json);
  Map<String, dynamic> toJson() => _$SetToJson(this);
}
