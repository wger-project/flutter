/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:intl/intl.dart';

num toNum(String e) {
  return num.parse(e);
}

String toString(num e) {
  return e.toString();
}

/*
 * Converts a datetime to ISO8601 date format, but only the date.
 * Needed e.g. when the wger api only expects a date and no time information.
 */
String toDate(DateTime dateTime) {
  if (dateTime == null) {
    return null;
  }
  return DateFormat('yyyy-MM-dd').format(dateTime).toString();
}

/*
 * Converts a time to a date object.
 * Needed e.g. when the wger api only sends a time but no date information.
 */
DateTime fromTime(String time) {
  if (time == null) {
    return null;
  }
  return DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()).toString() + ' ' + time);
}

/*
 * Converts a datetime to time.
 * Needed e.g. when the wger api only expects a time and no date information.
 */
String toTime(DateTime dateTime) {
  if (dateTime == null) {
    return null;
  }
  return DateFormat.Hms().format(dateTime).toString();
}
