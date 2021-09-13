/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/muscle.dart';

import 'exercise2.dart';

part 'base.g.dart';

@JsonSerializable(explicitToJson: true)
class ExerciseBase {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String uuid;

  @JsonKey(required: true, name: 'creation_date')
  final DateTime creationDate;

  @JsonKey(required: true, name: 'update_date')
  final DateTime updateDate;

  @JsonKey(required: true, name: 'category')
  late int categoryId;

  @JsonKey(ignore: true)
  late final ExerciseCategory category;

  @JsonKey(required: true, name: 'muscles')
  List<int> musclesIds = [];

  @JsonKey(ignore: true)
  List<Muscle> muscles = [];

  @JsonKey(required: true, name: 'muscles_secondary')
  List<int> musclesSecondaryIds = [];

  @JsonKey(ignore: true)
  List<Muscle> musclesSecondary = [];

  @JsonKey(required: true, name: 'equipment')
  List<int> equipmentIds = [];

  @JsonKey(ignore: true)
  List<Equipment> equipment = [];

  @JsonKey(ignore: true)
  List<ExerciseImage> images = [];

  @JsonKey(ignore: true)
  List<Exercise2> exercises = [];

  ExerciseBase(
      {required this.id,
      required this.uuid,
      required this.creationDate,
      required this.updateDate,
      List<Muscle>? muscles,
      List<Muscle>? musclesSecondary,
      List<Equipment>? equipment,
      List<ExerciseImage>? images,
      List<Comment>? tips,
      ExerciseCategory? category}) {
    this.images = images ?? [];
    this.equipment = equipment ?? [];
    this.musclesSecondary = musclesSecondary ?? [];
    this.muscles = muscles ?? [];
    if (category != null) {
      this.category = category;
      this.categoryId = category.id;
    }
  }

  ExerciseImage? get getMainImage {
    try {
      return images.firstWhere((image) => image.isMain);
    } on StateError {
      return null;
    }
  }

  set setCategory(ExerciseCategory category) {
    this.categoryId = category.id;
    this.category = category;
  }

  // Boilerplate
  factory ExerciseBase.fromJson(Map<String, dynamic> json) => _$ExerciseBaseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseBaseToJson(this);
}
