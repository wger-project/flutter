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

import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Cross-field validation for a workout log entry, mirroring the
/// reachable part of the backend `WorkoutLog.clean()` rule: at least
/// one of [repetitions] or [weight] must be set.
String? validateWorkoutLogCrossField({
  required num? repetitions,
  required num? weight,
  required AppLocalizations i18n,
}) {
  if (repetitions == null && weight == null) {
    return i18n.weightOrRepsRequired;
  }
  return null;
}

/// Cross-field validation for a workout session, mirroring the backend
/// `WorkoutSession.clean()` rules:
///
/// - [timeStart] and [timeEnd] must both be set or both be empty,
/// - if both are set, [timeStart] must not be after [timeEnd].
String? validateWorkoutSessionTimes({
  required TimeOfDay? timeStart,
  required TimeOfDay? timeEnd,
  required AppLocalizations i18n,
}) {
  if ((timeStart == null) != (timeEnd == null)) {
    return i18n.timeStartEndBothOrNeither;
  }
  if (timeStart != null && timeEnd != null && timeStart.isAfter(timeEnd)) {
    return i18n.timeStartAhead;
  }
  return null;
}
