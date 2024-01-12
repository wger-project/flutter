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

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/models/workouts/weight_unit.dart';

/// Returns the text representation for a single setting, used in the gym mode
String repText(
  int? reps,
  RepetitionUnit repetitionUnitObj,
  num? weight,
  WeightUnit weightUnitObj,
  String? rir,
) {
  // TODO(x): how to (easily?) translate strings like the units or 'RiR'

  final List<String> out = [];

  if (reps != null) {
    out.add(reps.toString());

    // The default repetition unit is 'reps', which we don't show unless there
    // is no weight defined so that we don't just output something like "8" but
    // rather "8 repetitions". If there is weight we want to output "8 x 50kg",
    // since the repetitions are implied. If other units are used, we always
    // print them
    if (repetitionUnitObj.id != REP_UNIT_REPETITIONS || weight == 0 || weight == null) {
      out.add(repetitionUnitObj.name);
    }
  }

  if (weight != null && weight != 0) {
    out.add('×');
    out.add(weight.toString());
    out.add(weightUnitObj.name);
  }

  if (rir != null && rir != '') {
    out.add('\n');
    out.add('($rir RiR)');
  }

  return out.join(' ');
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

extension TimeOfDayExtension on TimeOfDay {
  bool isAfter(TimeOfDay other) {
    if (toMinutes() > other.toMinutes()) {
      return true;
    } else {
      return false;
    }
  }

  bool isBefore(TimeOfDay other) {
    if (toMinutes() < other.toMinutes()) {
      return true;
    } else {
      return false;
    }
  }

  int toMinutes() {
    return (hour * 60) + minute;
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDayAs(DateTime other) {
    final thisDay = DateTime(year, month, day);
    final otherDay = DateTime(other.year, other.month, other.day);

    return thisDay.isAtSameMomentAs(otherDay);
  }
}

void launchURL(String url, BuildContext context) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final launched = await launchUrl(Uri.parse(url));
  if (!launched) {
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text('Could not open $url.')),
    );
  }
}
