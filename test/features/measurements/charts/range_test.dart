/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/charts/range.dart';

void main() {
  group('ChartRange', () {
    test('the week is the shortest range, the full history the longest', () {
      final now = DateTime.now();

      expect(ChartRange.all.cutoff, isNull);
      expect(ChartRange.lastMonth.cutoff!.isAfter(ChartRange.last3Months.cutoff!), isTrue);
      expect(ChartRange.lastWeek.cutoff!.isAfter(ChartRange.lastMonth.cutoff!), isTrue);
      expect(ChartRange.lastWeek.cutoff!.isBefore(now), isTrue);
    });

    test('the week covers today plus the six days before it', () {
      // Seven calendar days in all: the count cutoff sits at midnight six
      // days back, so a weekday axis gets one letter per day
      final count = ChartRange.lastWeek.countCutoff!;
      final now = DateTime.now();

      expect(DateTime(now.year, now.month, now.day - 6), count);
    });

    test('the cutoff sits at the same midnight as the count cutoff', () {
      // Chart filter and count queries have to agree on the calendar days a
      // range covers, and the day buckets they compare against sit at midnight
      expect(ChartRange.lastWeek.cutoff, ChartRange.lastWeek.countCutoff);
      expect(ChartRange.lastMonth.cutoff, ChartRange.lastMonth.countCutoff);
    });

    test('the read cutoff leaves room for the widest average window', () {
      // 30 days of range plus the 30-day window the category may be set to
      final read = ChartRange.lastMonth.readCutoff!;

      expect(ChartRange.lastMonth.cutoff!.difference(read).inDays, greaterThanOrEqualTo(29));
    });

    test('the count cutoff is the range itself, with no lead', () {
      final count = ChartRange.lastMonth.countCutoff!;

      expect(ChartRange.lastMonth.cutoff!.difference(count).inHours, lessThan(24));
      expect(count.isAfter(ChartRange.lastMonth.readCutoff!), isTrue);
    });

    test('the query cutoffs stay the same across rebuilds', () {
      // They identify a provider: derived from the current instant, every
      // rebuild would watch a new one, re-query the database and drop what it
      // was showing. Unlike cutoff, which is only ever compared against.
      for (final range in ChartRange.values) {
        expect(range.readCutoff, range.readCutoff);
        expect(range.countCutoff, range.countCutoff);
      }
      expect(ChartRange.lastMonth.countCutoff!.hour, 0);
      expect(ChartRange.lastMonth.countCutoff!.minute, 0);
    });
  });
}
