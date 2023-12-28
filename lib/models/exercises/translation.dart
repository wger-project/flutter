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
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/language.dart';

part 'translation.g.dart';

@JsonSerializable()
class Translation extends Equatable {
  @JsonKey(required: true)
  final int? id;

  @JsonKey(required: true)
  final String? uuid;

  @JsonKey(required: true, name: 'language')
  late int languageId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late Language languageObj;

  @JsonKey(required: true, name: 'created')
  final DateTime? created;

  @JsonKey(required: true, name: 'exercise_base')
  late int? exerciseId;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final String description;

  @JsonKey(includeFromJson: true, includeToJson: false)
  List<Comment> notes = [];

  @JsonKey(includeFromJson: true, includeToJson: false)
  List<Alias> aliases = [];

  Translation({
    this.id,
    this.uuid,
    this.created,
    required this.name,
    required this.description,
    int? exerciseId,
    language,
  }) {
    if (exerciseId != null) {
      this.exerciseId = exerciseId;
    }

    if (language != null) {
      languageObj = language;
      languageId = language.id;
    }
  }

  set exercise(Exercise exercise) {
    exerciseId = exercise.id;
  }

  set language(Language language) {
    languageObj = language;
    languageId = language.id;
  }

  // Boilerplate
  factory Translation.fromJson(Map<String, dynamic> json) => _$TranslationFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationToJson(this);

  @override
  List<Object?> get props => [
        id,
        exerciseId,
        uuid,
        languageId,
        created,
        name,
        description,
      ];
}
