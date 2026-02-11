/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

part 'repetition_unit.g.dart';

@JsonSerializable()
class RepetitionUnit {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String name;

  const RepetitionUnit({required this.id, required this.name});

  @override
  String toString() {
    return 'RepetitionUnit(id: $id, name: $name)';
  }

  // Boilerplate
  factory RepetitionUnit.fromJson(Map<String, dynamic> json) => _$RepetitionUnitFromJson(json);

  Map<String, dynamic> toJson() => _$RepetitionUnitToJson(this);
}
