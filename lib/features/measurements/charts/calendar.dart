/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

/// Calendar-day arithmetic for the charts, in one place because it is easy to
/// get subtly wrong: a Duration is wall-clock time and a DST day is 23 or 25
/// hours long, so days are shifted through the date components and counted in
/// UTC, never added as multiples of 24 hours.
library;

/// [date]'s calendar day, i.e. its midnight.
DateTime dayOf(DateTime date) => DateTime(date.year, date.month, date.day);

/// The calendar day [days] days after [day] (negative for before), at midnight.
DateTime shiftDays(DateTime day, int days) => DateTime(day.year, day.month, day.day + days);

/// The Monday of the week [date] falls into, at midnight.
DateTime weekStart(DateTime date) => shiftDays(date, -(date.weekday - 1));

/// Whole days from [from] to [to], both taken as calendar days.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
