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

  double? height;
  double? weight;

  Profile({
    required this.username,
    required this.emailVerified,
    required this.isTrustworthy,
    required this.email,
    required this.weightUnitStr,
    this.height,
    this.weight,
  });
  double calculateBmi({double? weightOverride}) {
    // 1. Wir definieren, welches Gewicht wir nutzen (Override ODER Profil)
    final double? effectiveWeight = weightOverride ?? weight;

    // 2. Prüfen: Ist dieses 'effectiveWeight' da? Und ist die Größe da?
    // Wenn eins davon fehlt, brechen wir ab.
    if (effectiveWeight == null || height == null || height == 0) {
      return 0.0;
    }

    // 3. Größe vorbereiten (hier ist height! sicher, wegen dem if oben)
    double heightInMeters = height!;
    if (heightInMeters > 3.0) {
      heightInMeters = heightInMeters / 100.0;
    }

    // 4. DIE ENTSCHEIDENDE ÄNDERUNG:
    // Wir rechnen mit 'effectiveWeight', NICHT mit 'weight!'
    return effectiveWeight / (heightInMeters * heightInMeters);
  }

  // Boilerplate
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
