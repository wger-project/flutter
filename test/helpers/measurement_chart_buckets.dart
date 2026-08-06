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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/features/measurements/models/measurement_bucket.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';

/// One bucket per entry, oldest first: what the aggregated query returns for a
/// series short enough not to be condensed, which every widget fixture is.
/// Condensing is covered where it happens, in the repository and `downsample`.
List<MeasurementBucket> entryBuckets(Iterable<MeasurementEntry> entries, {DateTime? since}) => [
  for (final entry in entries)
    if (since == null || !entry.date.isBefore(since))
      MeasurementBucket(
        start: entry.date,
        unit: entry.extraData?['unit'] as String?,
        count: 1,
        sum: entry.value,
        min: entry.extraData?['min'] as num? ?? entry.value,
        max: entry.extraData?['max'] as num? ?? entry.value,
      ),
]..sort((a, b) => a.start.compareTo(b.start));

/// What `measurementChartBucketsProvider.overrideWith` takes.
typedef ChartBucketsStub =
    Stream<List<MeasurementBucket>> Function(
      Ref,
      (String, DateTime?, MeasurementBucketLevel),
    );

/// Serves the chart query from the entries [categories] already carry, group
/// components included, so a widget test seeds one list rather than two.
ChartBucketsStub chartBucketsFrom(List<MeasurementCategory> categories) {
  final byId = {
    for (final category in categories) ...{
      category.id: category,
      for (final child in category.children) child.id: child,
    },
  };

  return (ref, args) {
    final (categoryId, since, _) = args;
    return Stream.value(entryBuckets(byId[categoryId]?.entries ?? const [], since: since));
  };
}
