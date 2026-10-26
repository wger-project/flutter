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

import 'package:timezone/timezone.dart' as tz;

/// The calendar day of [instant] in the IANA zone [zoneName], as the plain
/// year/month/day [DateTime] that [DateTimeExtension.isSameDayAs] compares
///
/// A null, empty or unknown name falls back to the device zone, mirroring the
/// fallback of the server's UserProfile.zone_info.
DateTime dayIn(DateTime instant, String? zoneName) {
  if (zoneName != null && zoneName.isNotEmpty) {
    try {
      final zoned = tz.TZDateTime.from(instant, tz.getLocation(zoneName));
      return DateTime(zoned.year, zoned.month, zoned.day);
    } on tz.LocationNotFoundException {
      // An unknown name reads like an unreported zone
    }
  }

  final local = instant.toLocal();
  return DateTime(local.year, local.month, local.day);
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
///
/// Counts calendar days, not elapsed time: the range is measured between the
/// two days as UTC midnights, so a daylight-saving switch inside it cannot
/// swallow the last day.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final start = DateTime.utc(first.year, first.month, first.day);
  final end = DateTime.utc(last.year, last.month, last.day);

  final dayCount = end.difference(start).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(start.year, start.month, start.day + index),
  );
}

extension DateTimeExtension on DateTime {
  bool isSameDayAs(DateTime other) {
    final thisDay = DateTime(year, month, day);
    final otherDay = DateTime(other.year, other.month, other.day);

    return thisDay.isAtSameMomentAs(otherDay);
  }
}
