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
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/helpers/i18n.dart';

part 'muscle.g.dart';

@JsonSerializable()
class Muscle extends Equatable {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true, name: 'name_en')
  final String nameEn;

  @JsonKey(required: true, name: 'is_front')
  final bool isFront;

  const Muscle({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.isFront,
  });

  // Boilerplate
  factory Muscle.fromJson(Map<String, dynamic> json) => _$MuscleFromJson(json);

  Map<String, dynamic> toJson() => _$MuscleToJson(this);

  @override
  List<Object?> get props => [id, name, isFront];

  String nameTranslated(BuildContext context) {
    return name + (nameEn.isNotEmpty ? ' (${getTranslation(nameEn, context)})' : '');
  }

  @override
  String toString() {
    return 'Muscle: $id - $name';
  }
}
