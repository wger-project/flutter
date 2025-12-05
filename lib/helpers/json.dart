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

num? stringToNumNull(String? e) {
  return e == null ? null : num.parse(e);
}

num stringOrIntToNum(dynamic e) {
  if (e is int) {
    return e.toDouble(); // Convert int to double (a type of num)
  }
  return num.tryParse(e) ?? 0;
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
String? dateToYYYYMMDD(DateTime? dateTime) {
  if (dateTime == null) {
    return null;
  }
  return DateFormat('yyyy-MM-dd').format(dateTime);
}

/// Convert a date to UTC and then to an ISO8601 string.
///
/// This makes sure that the serialized data has correct timezone information.
/// Otherwise the django backend will possibly treat the date as local time,
/// which will not be correct in most cases.
String dateToUtcIso8601(DateTime dateTime) {
  return dateTime.toUtc().toIso8601String();
}

/// Converts an ISO8601 datetime string in UTC to a local DateTime object.
///
/// Needs to be used in conjunction with [dateToUtcIso8601] in the models to
/// correctly handle timezones.
DateTime utcIso8601ToLocalDate(String dateTime) {
  return DateTime.parse(dateTime).toLocal();
}

/*
 * Converts a time to a date object.
 * Needed e.g. when the wger api only sends a time but no date information.
 */
TimeOfDay stringToTime(String? time) {
  time ??= '00:00';
  return TimeOfDay.fromDateTime(DateTime.parse('2020-01-01 $time'));
}

TimeOfDay? stringToTimeNull(String? time) {
  if (time == null) {
    return null;
  }

  return TimeOfDay.fromDateTime(DateTime.parse('2020-01-01 $time'));
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
