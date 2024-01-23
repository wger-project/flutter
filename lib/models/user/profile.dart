/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  @JsonKey(required: true)
  String username;

  @JsonKey(required: true, name: 'email_verified')
  bool emailVerified;

  @JsonKey(required: true, name: 'is_trustworthy')
  bool isTrustworthy;

  @JsonKey(required: true, name: 'weight_unit')
  String weightUnitStr;

  bool get isMetric => weightUnitStr == 'kg';

  @JsonKey(required: true)
  String email;

  Profile({
    required this.username,
    required this.emailVerified,
    required this.isTrustworthy,
    required this.email,
    required this.weightUnitStr,
  });

  // Boilerplate
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
