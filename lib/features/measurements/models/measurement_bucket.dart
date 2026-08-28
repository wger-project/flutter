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

/// Points a chart is condensed to. Plotting more than the chart has pixels
/// only overdraws: a season of raw heart rate samples is tens of thousands of
/// values on a few hundred pixels, and comes out as a solid block.
const measurementChartMaxPoints = 200;

/// Calendar units a category's entries are condensed into, finest first.
///
/// The calendar rather than equal slices of the span: these metrics have a
/// daily rhythm, so slices that do not line up with a day each catch a
/// different phase of it and the chart oscillates at the slice frequency.
enum MeasurementBucketUnit {
  /// One bucket per entry, i.e. no condensing.
  entry,
  hour,
  day,
  week,
  month,
}

/// The level a chart wants its points at.
///
/// Only [auto] is free to pick from the whole ladder; the others exist because
/// the chart itself is built on a calendar unit and coarser points would draw
/// a grid of the wrong cells.
enum MeasurementBucketLevel {
  /// The finest unit that keeps the series under the point limit.
  auto,

  /// One point per calendar day, whatever the point count.
  day,

  /// One point per calendar week (starting Monday).
  week,
}

/// How often one value occurred, the histogram's counterpart to a bucket.
///
/// Grouped by the unit it was entered in for the same reason: the value still
/// goes through the conversion helper before it is binned.
class MeasurementValueCount {
  const MeasurementValueCount({
    required this.value,
    required this.unit,
    required this.count,
    required this.newest,
  });

  final num value;
  final String? unit;
  final int count;

  /// Newest entry holding this value, so the histogram can mark where the user
  /// stands today.
  final DateTime newest;
}

/// One calendar bucket of a category's entries, as SQLite aggregated it.
///
/// Grouped by bucket *and* by the unit the values were entered in, so a
/// category holding mixed units yields one bucket per unit and the caller
/// converts each before merging them.
class MeasurementBucket {
  const MeasurementBucket({
    required this.start,
    required this.unit,
    required this.count,
    required this.sum,
    required this.min,
    required this.max,
  });

  /// Start of the bucket in the local zone; the entry's own timestamp at the
  /// [MeasurementBucketUnit.entry] level.
  final DateTime start;

  /// Unit the values in it were entered in (`extra_data.unit`), null when they
  /// carry none and the category unit applies.
  final String? unit;

  final int count;
  final num sum;

  /// Lowest and highest value the bucket stands for. A daily aggregate
  /// contributes its stored bounds rather than its value, so condensing one
  /// keeps the true extremes.
  final num min;
  final num max;
}
