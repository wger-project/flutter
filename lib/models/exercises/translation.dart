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
import 'package:wger/models/exercises/alias.dart';
import 'package:wger/models/exercises/comment.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/language.dart';

class Translation extends Equatable {
  final int? id;
  final String? uuid;
  late int languageId;
  late Language languageObj;
  final DateTime? created;
  late int? exerciseId;
  final String name;
  final String description;

  List<Comment> notes = [];
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
