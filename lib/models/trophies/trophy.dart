/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2025 wger Team
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

part 'trophy.g.dart';

enum TrophyType { time, volume, count, sequence, date, pr, other }

@JsonSerializable()
class Trophy {
  @JsonKey(required: true)
  final int id;

  @JsonKey(required: true)
  final String uuid;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final String description;

  @JsonKey(required: true)
  final String image;

  @JsonKey(required: true, name: 'trophy_type')
  final TrophyType type;

  @JsonKey(required: true, name: 'is_hidden')
  final bool isHidden;

  @JsonKey(required: true, name: 'is_progressive')
  final bool isProgressive;

  Trophy({
    required this.id,
    required this.uuid,
    required this.name,
    required this.description,
    required this.image,
    required this.type,
    required this.isHidden,
    required this.isProgressive,
  });

  // Boilerplate
  factory Trophy.fromJson(Map<String, dynamic> json) => _$TrophyFromJson(json);

  Map<String, dynamic> toJson() => _$TrophyToJson(this);
}
