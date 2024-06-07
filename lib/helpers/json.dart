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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

num stringToNum(String? e) {
  return e == null ? 0 : num.parse(e);
}

String? numToString(num? e) {
  if (e == null) {
    return null;
  }

  return e.toString();
}

/*
 * Converts a datetime to ISO8601 date format, but only the date.
 * Needed e.g. when the wger api only expects a date and no time information.
 */
String? toDate(DateTime? dateTime) {
  if (dateTime == null) {
    return null;
  }
  return DateFormat('yyyy-MM-dd').format(dateTime);
}

/*
 * Converts a time to a date object.
 * Needed e.g. when the wger api only sends a time but no date information.
 */
TimeOfDay stringToTime(String? time) {
  final String out = time ?? '00:00';
  return TimeOfDay.fromDateTime(DateTime.parse('2020-01-01 $out'));
}

/*
 * Converts a datetime to time.
 */
String? timeToString(TimeOfDay? time) {
  if (time == null) {
    return null;
  }
  return const DefaultMaterialLocalizations().formatTimeOfDay(time, alwaysUse24HourFormat: true);
}
