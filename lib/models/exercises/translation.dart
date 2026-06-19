/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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
import 'package:wger/models/core/language.dart';
import 'package:wger/models/exercises/alias.dart';
import 'package:wger/models/exercises/comment.dart';

class Translation extends Equatable {
  final int? id;
  final String? uuid;
  final Language language;
  final DateTime? created;
  final int? exerciseId;
  final String name;
  final String description;
  final String descriptionSource;
  final List<Comment> notes;
  final List<Alias> aliases;

  int get languageId => language.id;

  const Translation({
    this.id,
    this.uuid,
    this.created,
    required this.name,
    required this.description,
    this.descriptionSource = '',
    this.exerciseId,
    required this.language,
    this.notes = const [],
    this.aliases = const [],
  });

  @override
  List<Object?> get props => [
    id,
    exerciseId,
    uuid,
    languageId,
    created,
    name,
    description,
    descriptionSource,
  ];
}
