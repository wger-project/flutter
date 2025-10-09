/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) wger Team
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

/// Returns a timezone aware DateTime object from a date and time string.
DateTime getDateTimeFromDateAndTime(String date, String time) {
  return DateTime.parse('$date $time');
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

/// Formats a Duration into a human-readable string with years, months, and days
String humanDuration(DateTime startDate, DateTime endDate) {
  var years = endDate.year - startDate.year;
  var months = endDate.month - startDate.month;
  var days = endDate.day - startDate.day;

  if (months < 0) {
    months += 12;
    years -= 1;
  }

// if we overcounted the days, it's a bit trickier to solve than overcounting months
// e.g. consider a start date february 10 and end date june 8
// -> days = -2
// -> months = 4
// the proper answer can be thought of in 3 ways:
// * count whole months first, then days: from febr 10 to may 10, and then to june 8. that's 3 months + (num_days_in_may - 10 + 8 days)
// * count days first, then whole months: from febr 10 to march 8, and then to june 8. that's (num_days_in_feb - 10 + 8 days) + 3 months
// * technically, one can also use any month to adjust the day: e.g.
//   count months from febr 10 to april 10, count days to may 8, and count months again to june 8.
// probably no-one uses the last method. The first approach seems most natural.
// it means we need to know the number of days (aka the last day index) of the month before endDate
// which we can do by setting the day to 0 and asking for the day
  if (days < 0) {
    days += DateTime(endDate.year, endDate.month, 0).day;
    months -= 1;
  }

  final parts = <String>[];
  if (years > 0) {
    parts.add('$years year${years == 1 ? '' : 's'}');
  }
  if (months > 0) {
    parts.add('$months month${months == 1 ? '' : 's'}');
  }
  if (days > 0) {
    parts.add('$days day${days == 1 ? '' : 's'}');
  }

  if (parts.isEmpty) {
    return 'Duration: 0 days';
  }
  return 'Duration: ${parts.join(', ')}';
}

extension DateTimeExtension on DateTime {
  bool isSameDayAs(DateTime other) {
    final thisDay = DateTime(year, month, day);
    final otherDay = DateTime(other.year, other.month, other.day);

    return thisDay.isAtSameMomentAs(otherDay);
  }
}
