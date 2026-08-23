/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'package:drift/drift.dart' as drift;
import 'package:wger/core/consts.dart';
import 'package:wger/database/powersync/database.dart';

/// The user's editable profile preferences.
class UserProfile {
  /// The range the server's validators allow for [height], in cm. A value
  /// outside them comes back as a 400, so the form refuses it first.
  static const minHeightCm = 140;
  static const maxHeightCm = 230;

  final int id;
  String weightUnitStr;

  /// Body height in cm, null for a profile that has none
  final int? height;

  /// IANA timezone name. Empty or null means no client has reported one.
  final String? timeZone;

  UserProfile({required this.id, required this.weightUnitStr, this.height, this.timeZone});

  bool get isMetric => weightUnitStr == 'kg';

  /// Weight unit implied by the metric preference: kg for metric users, lb otherwise.
  int get defaultWeightUnitId => isMetric ? WEIGHT_UNIT_KG : WEIGHT_UNIT_LB;

  /// Drift companion for local UPDATE writes routed through PowerSync.
  UserProfileTableCompanion toCompanion() {
    return UserProfileTableCompanion(
      id: drift.Value(id),
      weightUnitStr: drift.Value(weightUnitStr),
      height: drift.Value(height),
      timeZone: drift.Value(timeZone),
    );
  }
}
