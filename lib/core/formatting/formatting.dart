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

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// A short date format (`DateFormat.yMd`) bound to the current locale's
/// language. Chain further patterns (e.g. `.add_Hm()`) as needed.
DateFormat localizedDate(BuildContext context) =>
    DateFormat.yMd(Localizations.localeOf(context).languageCode);

/// A decimal number format bound to the current locale.
NumberFormat localizedNumberFormat(BuildContext context) =>
    NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

/// A date in the past as a relative phrase ("today", "3 weeks ago").
///
/// Counts calendar days rather than elapsed hours, so an entry from late
/// yesterday still reads as yesterday this morning. The unit grows with the
/// distance: days within a week, then weeks, months, years. Matches react's
/// dateToRelative for past dates, which reaches the same output through Intl.
///
/// A date ahead of [now] reads as today: the pickers do not offer one, so it
/// only ever arrives through clock skew between devices, and the phrases for
/// it (react has them from Intl) would be four more strings to translate for
/// a case nobody is looking at.
String relativeDate(BuildContext context, DateTime date, {DateTime? now}) {
  final today = now ?? DateTime.now();
  // Calendar arithmetic in UTC, so a DST day is not 23 or 25 hours long
  final elapsed = DateTime.utc(
    today.year,
    today.month,
    today.day,
  ).difference(DateTime.utc(date.year, date.month, date.day)).inDays;
  final days = max(0, elapsed);

  final i18n = AppLocalizations.of(context);
  if (days < DateTime.daysPerWeek) {
    return i18n.relativeDaysAgo(days);
  }
  if (days < 31) {
    return i18n.relativeWeeksAgo((days / 7).round());
  }
  if (days < 365) {
    return i18n.relativeMonthsAgo((days / 30).round());
  }
  return i18n.relativeYearsAgo((days / 365).round());
}

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
///
/// [decimals] caps the fraction digits, for at-a-glance readings; without it
/// the locale default (up to three) applies. A duration ignores it, hours and
/// minutes have no decimals to cap.
String measurementValue(BuildContext context, num value, String unit, {int? decimals}) =>
    unit == durationUnit
    ? hoursAndMinutes(value, Localizations.localeOf(context).toString())
    : (decimals == null
              ? localizedNumberFormat(context)
              : (localizedNumberFormat(context)..maximumFractionDigits = decimals))
          .format(value);

/// The unit as it is shown. A duration is stored in minutes but read in hours,
/// and the symbol stays untranslated like the units of the other categories.
String measurementUnit(String unit) => unit == durationUnit ? 'h' : unit;

/// An already formatted value followed by its unit, or on its own where there
/// is none: a step count is a bare number, and so may be a free-form category.
String unitSuffixed(String formatted, String unit) =>
    unit.isEmpty ? formatted : '$formatted ${measurementUnit(unit)}';

/// A measured value with its unit. [decimals] as in [measurementValue].
String measurementWithUnit(BuildContext context, num value, String unit, {int? decimals}) =>
    unitSuffixed(measurementValue(context, value, unit, decimals: decimals), unit);

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
/// How close the ends of a series have to be for its axis to count as flat:
/// a spread that only shows up in the last digits of a double.
const _FLAT_RELATIVE = 1e-9;

/// Room left around a flat series, as a share of the value it sits at.
const _FLAT_PADDING = 0.05;

/// Bounds and tick interval of a value axis, null where fl_chart may pick them
/// itself.
///
/// Two cases are taken out of its hands. Durations are read in hours, see
/// [durationAxis]. And a series whose values are all the same leaves a range
/// of nothing: fl_chart divides that range into steps and walks the axis one
/// step at a time, so a step below the last value's own precision never
/// advances the walk, and it generates labels until the heap gives out. A flat
/// series is ordinary (a weight that did not move, a calculation that stays
/// put), so the axis gets room around the value instead.
({double min, double max, double? interval})? valueAxis(
  String unit,
  num min,
  num max,
) {
  final duration = durationAxis(unit, min, max);
  if (duration != null) {
    return duration;
  }

  if ((max - min).abs() > max.abs() * _FLAT_RELATIVE) {
    return null;
  }

  // A value of zero has no magnitude to take a share of
  final padding = max.abs() * _FLAT_PADDING;
  return (
    min: (max - (padding == 0 ? 1 : padding)).toDouble(),
    max: (max + (padding == 0 ? 1 : padding)).toDouble(),
    interval: null,
  );
}

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
