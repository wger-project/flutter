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

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/models/exercises/alias.dart';
import 'package:wger/models/exercises/base.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/language.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/video.dart';

part 'exercise.g.dart';

@JsonSerializable()
class Exercise extends Equatable {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true, name: 'exercise_base')
  final int baseId;

  @JsonKey(required: true)
  final String uuid;

  @JsonKey(required: true, name: 'language')
  final int languageId;

  @JsonKey(ignore: true)
  late Language language;

  @JsonKey(required: true, name: 'creation_date')
  final DateTime creationDate;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final String description;

  @JsonKey(ignore: true)
  late ExerciseBase base;

  @JsonKey(ignore: true)
  List<Comment> tips = [];

  @JsonKey(ignore: true)
  List<Alias> alias = [];

  Exercise(
      {required this.id,
      required this.baseId,
      required this.uuid,
      required this.creationDate,
      required this.languageId,
      required this.name,
      required this.description,
      base,
      language}) {
    if (base != null) {
      this.base = base;
    }

    if (language != null) {
      this.language = language;
    }
  }

  ExerciseImage? get getMainImage => base.getMainImage;
  ExerciseCategory get category => base.category;
  List<ExerciseImage> get images => base.images;
  List<Equipment> get equipment => base.equipment;
  List<Muscle> get muscles => base.muscles;
  List<Muscle> get musclesSecondary => base.musclesSecondary;

  // Boilerplate
  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  @override
  List<Object?> get props => [
        id,
        baseId,
        uuid,
        languageId,
        creationDate,
        name,
        description,
        base,
      ];
}
