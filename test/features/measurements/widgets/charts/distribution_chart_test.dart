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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/widgets/charts/distribution_chart.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SizedBox(width: 400, height: 300, child: child),
  ),
);

void main() {
  group('niceBinWidth', () {
    test('rounds the span split into ~20 bins up to 1, 2 or 5 times a power of ten', () {
      // span 14.6 / 20 = 0.73 -> 1, not an edge like 59.3-61.3
      expect(niceBinWidth(59.3, 73.9), 1);
      // span 30000 / 20 = 1500 -> 2000
      expect(niceBinWidth(0, 30000), 2000);
      // span 9 / 20 = 0.45 -> 0.5
      expect(niceBinWidth(1, 10), 0.5);
    });

    test('a span of nothing still has a width', () {
      expect(niceBinWidth(80, 80), 1);
    });
  });

  group('buildWeightedHistogram', () {
    test('counts a value as often as it occurred', () {
      // What the aggregated query hands over: a year of readings arrives as
      // the distinct values it covers, with their counts
      final result = buildWeightedHistogram(
        [(value: 60, count: 30), (value: 61, count: 5)],
        latest: 61,
        binWidth: 1,
      );

      expect(result.counts, [30, 5]);
    });

    test('the median weighs the counts, not the distinct values', () {
      // Thirty readings at 60 and one at 90: the middle reading is a 60, which
      // an unweighted median over the two values would miss
      final result = buildWeightedHistogram(
        [(value: 60, count: 30), (value: 90, count: 1)],
        latest: 90,
        binWidth: 10,
      );

      expect(result.median, 60);
    });

    test('an even number of readings averages the two in the middle', () {
      final result = buildWeightedHistogram(
        [(value: 60, count: 1), (value: 70, count: 1)],
        latest: 70,
        binWidth: 10,
      );

      expect(result.median, 65);
    });
  });

  group('buildWeightedHistogram bins', () {
    test('aligns the bin edges to round multiples of the width', () {
      final result = buildWeightedHistogram(
        [
          (value: 79.7, count: 1),
          (value: 82.3, count: 1),
        ],
        latest: 0,
        binWidth: 0.5,
      );

      expect(result.firstEdge, 79.5);
      expect(result.lowerEdgeOf(1), 80);
      expect(result.upperEdgeOf(result.counts.length - 1), 82.5);
    });

    test('keeps empty bins between the occupied ones, a gap is information', () {
      final result = buildWeightedHistogram(
        [
          (value: 60, count: 1),
          (value: 61, count: 1),
          (value: 65, count: 1),
        ],
        latest: 0,
        binWidth: 2,
      );

      expect(result.counts, [2, 0, 1]);
    });

    test('takes the median of the values, odd and even', () {
      final odd = buildWeightedHistogram(
        [
          (value: 60, count: 1),
          (value: 62, count: 1),
          (value: 70, count: 1),
        ],
        latest: 0,
        binWidth: 2,
      );
      expect(odd.median, 62);

      final even = buildWeightedHistogram(
        [
          (value: 60, count: 1),
          (value: 63, count: 1),
          (value: 65, count: 1),
          (value: 70, count: 1),
        ],
        latest: 0,
        binWidth: 2,
      );
      expect(even.median, 64);
    });

    test('derives a width from the span when the type brings none', () {
      final result = buildWeightedHistogram([
        (value: 59.3, count: 1),
        (value: 73.9, count: 1),
      ], latest: 0);

      expect(result.binWidth, 1);
    });

    test('doubles the width until an outlier no longer stretches it into hundreds of bins', () {
      // 20 to 350 at 0.5 kg would be 661 bins; doubling keeps the edges round
      final result = buildWeightedHistogram(
        [
          (value: 20, count: 1),
          (value: 80, count: 1),
          (value: 350, count: 1),
        ],
        latest: 0,
        binWidth: 0.5,
      );

      expect(result.binWidth, 4);
      expect(result.counts.length, lessThanOrEqualTo(100));
      expect(result.counts.sum, 3);
    });
  });

  group('MeasurementDistributionWidgetFl', () {
    const counted = <ValueCount>[
      (value: 60, count: 1),
      (value: 61, count: 1),
      (value: 65, count: 1),
    ];

    testWidgets('renders nothing for no values instead of crashing', (tester) async {
      await tester.pumpWidget(
        _wrap(const MeasurementDistributionWidgetFl([], latest: 0, unit: 'kg')),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('reads out the median and the newest value, which the lines only place', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const MeasurementDistributionWidgetFl(counted, latest: 65, unit: 'kg', binWidth: 2)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Median: 61 kg', findRichText: true), findsOneWidget);
      expect(find.textContaining('Latest: 65 kg', findRichText: true), findsOneWidget);
    });

    // Mirrors the widget's own layout: the read-out line on top, the count
    // labels to the left, the bins sharing the rest of the width
    Offset firstBinCenter(WidgetTester tester, {required int bins}) {
      const readoutHeight = 20.0;
      const countLabelWidth = 30.0;
      final box = tester.getRect(find.byType(MeasurementDistributionWidgetFl));
      final step = (box.width - countLabelWidth) / bins;
      return Offset(box.left + countLabelWidth + step / 2, box.top + readoutHeight + 100);
    }

    testWidgets('a tapped bin reads out as its range and count', (tester) async {
      await tester.pumpWidget(
        _wrap(const MeasurementDistributionWidgetFl(counted, latest: 65, unit: 'kg', binWidth: 2)),
      );
      await tester.pumpAndSettle();

      // Bins are [60-62): 2, [62-64): 0, [64-66): 1
      await tester.tapAt(firstBinCenter(tester, bins: 3));
      await tester.pumpAndSettle();

      expect(find.textContaining('60-62 kg: 2 entries'), findsOneWidget);

      // Tapping the bin again clears the selection
      await tester.tapAt(firstBinCenter(tester, bins: 3));
      await tester.pumpAndSettle();
      expect(find.textContaining('Median:', findRichText: true), findsOneWidget);
    });

    testWidgets('counts read as days for a metric summed per day', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MeasurementDistributionWidgetFl(
            counted,
            latest: 65,
            unit: 'kg',
            binWidth: 2,
            countsAreDays: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tapAt(firstBinCenter(tester, bins: 3));
      await tester.pumpAndSettle();

      expect(find.textContaining('60-62 kg: 2 days'), findsOneWidget);
    });
  });
}
