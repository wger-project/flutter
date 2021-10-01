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

  @JsonKey(required: false, ignore: true)
  late int categoryId;

  @JsonKey(required: true, name: 'category')
  late final ExerciseCategory categoryObj;

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

  Exercise(
      {required this.id,
      required this.uuid,
      required this.creationDate,
      required this.name,
      required this.description,
      List<Muscle>? muscles,
      List<Muscle>? musclesSecondary,
      List<Equipment>? equipment,
      List<ExerciseImage>? images,
      List<Comment>? tips,
      ExerciseCategory? category}) {
    this.tips = tips ?? [];
    this.images = images ?? [];
    this.equipment = equipment ?? [];
    this.musclesSecondary = musclesSecondary ?? [];
    this.muscles = muscles ?? [];
    if (category != null) {
      categoryObj = category;
      categoryId = category.id;
    }
  }

  ExerciseImage? get getMainImage {
    try {
      return images.firstWhere((image) => image.isMain);
    } on StateError catch (e) {
      return null;
    }
  }

  set category(ExerciseCategory category) {
    categoryId = category.id;
    categoryObj = category;
  }

  // Boilerplate
  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}
