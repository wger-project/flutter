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

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// A short date format (`DateFormat.yMd`) bound to the current locale's
/// language. Chain further patterns (e.g. `.add_Hm()`) as needed.
DateFormat localizedDate(BuildContext context) =>
    DateFormat.yMd(Localizations.localeOf(context).languageCode);

/// A decimal number format bound to the current locale.
NumberFormat localizedNumberFormat(BuildContext context) =>
    NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

/// The unit a duration is stored in, which is what the health platforms deliver.
const durationUnit = 'min';

/// A duration in minutes as hours and minutes, e.g. 452 as `7:32`.
///
/// Neither intl nor intl4x has a duration formatter, so the parts are put
/// together the way flutter_localizations does it for a time of day: the
/// digits come from the locale (`۷:۳۲` in Persian) and the minutes are zero
/// padded through the number format rather than through the string. The sign
/// is ours, a duration is only ever negative here as a change between two of
/// them. The web side reaches the same output through Intl.DurationFormat.
String hoursAndMinutes(num minutes, String locale) {
  final rounded = minutes.round();
  final absolute = rounded.abs();

  return '${rounded < 0 ? '-' : ''}'
      '${NumberFormat.decimalPattern(locale).format(absolute ~/ 60)}:'
      '${NumberFormat('00', locale).format(absolute % 60)}';
}

/// A measured value on its own, formatted the way its unit is read. For the
/// ends of a range, where only the last one carries the unit.
String measurementValue(BuildContext context, num value, String unit) => unit == durationUnit
    ? hoursAndMinutes(value, Localizations.localeOf(context).toString())
    : localizedNumberFormat(context).format(value);

/// The unit as it is shown. A duration is stored in minutes but read in hours,
/// and the symbol stays untranslated like the units of the other categories.
String measurementUnit(String unit) => unit == durationUnit ? 'h' : unit;

/// A measured value with its unit.
String measurementWithUnit(BuildContext context, num value, String unit) =>
    '${measurementValue(context, value, unit)} ${measurementUnit(unit)}';

/// Ticks a duration axis aims for, few enough that the labels stay apart.
const _DURATION_TICKS = 6;

const _MINUTES_PER_HOUR = 60;

/// Bounds and tick interval of an axis of durations, null for every other
/// unit, where fl_chart picks them.
///
/// A duration is read in hours, so a tick belongs on a whole one: an axis
/// labelled 6:40, 8:20, 10:00 is arithmetically correct and unreadable. The
/// interval grows in whole hours until few enough ticks are left, and the
/// bounds are widened to the hours around the data, because fl_chart counts
/// the ticks from the lower bound.
({double min, double max, double interval})? durationAxis(
  String unit,
  num min,
  num max,
) {
  if (unit != durationUnit) {
    return null;
  }

  final from = (min / _MINUTES_PER_HOUR).floor() * _MINUTES_PER_HOUR;
  final to = (max / _MINUTES_PER_HOUR).ceil() * _MINUTES_PER_HOUR;
  final hours = ((to - from) / _MINUTES_PER_HOUR).clamp(1, double.infinity);
  final interval = (hours / _DURATION_TICKS).ceil() * _MINUTES_PER_HOUR;

  // The top follows the interval rather than the data: a bound that ended
  // below the last tick would cut the values it was derived from
  final top = from + ((to - from) / interval).ceil() * interval;

  return (min: from.toDouble(), max: top.toDouble(), interval: interval.toDouble());
}
