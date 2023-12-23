import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wger/models/exercises/alias.dart';
import 'package:wger/models/exercises/comment.dart';

part 'exercise_model.freezed.dart';
part 'exercise_model.g.dart';

@freezed
class ExerciseData with _$ExerciseData {
  factory ExerciseData({
    required int id,
    required String uuid,
    @JsonKey(name: 'language') required int languageId,
    @JsonKey(required: true, name: 'exercise_base') required int baseId,
    required String description,
    required String name,
    required List<Alias> aliases,
    required List<Comment> notes,
  }) = _ExerciseData;

  factory ExerciseData.fromJson(Map<String, dynamic> json) =>
      _$ExerciseDataFromJson(json);
}
