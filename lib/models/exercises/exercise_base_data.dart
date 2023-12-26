import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/exercise_model.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/video.dart';

part 'exercise_base_data.freezed.dart';
part 'exercise_base_data.g.dart';

@freezed
class ExerciseBaseData with _$ExerciseBaseData {
  factory ExerciseBaseData({
    required int id,
    required String uuid,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'created') required DateTime created,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'last_update') required DateTime lastUpdate,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'last_update_global') required DateTime lastUpdateGlobal,
    required ExerciseCategory category,
    required List<Muscle> muscles,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'muscles_secondary') required List<Muscle> musclesSecondary,
    required List<Equipment> equipment,
    required List<ExerciseData> exercises,
    required List<ExerciseImage> images,
    required List<Video> videos,
  }) = _ExerciseBaseData;

  factory ExerciseBaseData.fromJson(Map<String, dynamic> json) => _$ExerciseBaseDataFromJson(json);
}
