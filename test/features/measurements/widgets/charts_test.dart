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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SizedBox(width: 400, height: 300, child: child),
  ),
);

void main() {
  MeasurementChartEntry entry(num value, DateTime date) => MeasurementChartEntry(value, date);

  group('MeasurementBarChartWidgetFl', () {
    testWidgets('renders without error for empty entries', (tester) async {
      await tester.pumpWidget(
        _wrap(const MeasurementBarChartWidgetFl([], 'steps')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MeasurementBarChartWidgetFl), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BarChart is present for non-empty entries', (tester) async {
      final entries = [
        entry(1000, DateTime(2026, 1, 1)),
        entry(2000, DateTime(2026, 1, 2)),
        entry(1500, DateTime(2026, 1, 3)),
      ];
      await tester.pumpWidget(_wrap(MeasurementBarChartWidgetFl(entries, 'steps')));
      await tester.pumpAndSettle();

      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('only labels a few dates on the x axis', (tester) async {
      final entries = List.generate(
        40,
        (i) => entry(1000 + i, DateTime(2026, 1, 1).add(Duration(days: i))),
      );
      await tester.pumpWidget(_wrap(MeasurementBarChartWidgetFl(entries, 'steps')));
      await tester.pumpAndSettle();

      final dateLabels = find.byWidgetPredicate(
        (w) => w is Text && RegExp(r'^\d+/\d+$').hasMatch(w.data ?? ''),
      );
      expect(dateLabels, findsNWidgets(4));
      // the labels are spread out and kept away from the axis edges
      expect(find.text('1/6'), findsOneWidget);
      expect(find.text('2/5'), findsOneWidget);
      expect(find.text('1/1'), findsNothing);
    });
  });

  group('MeasurementChartEntry', () {
    test('only counts as a range when both bounds are set', () {
      expect(entry(60, DateTime(2026, 1, 1)).hasRange, isFalse);
      expect(MeasurementChartEntry(60, DateTime(2026, 1, 1), min: 50).hasRange, isFalse);
      expect(
        MeasurementChartEntry(60, DateTime(2026, 1, 1), min: 50, max: 70).hasRange,
        isTrue,
      );
    });
  });

  group('MeasurementChartWidgetFl series', () {
    /// The chart data fl_chart actually receives
    LineChartData chartData(WidgetTester tester) =>
        tester.widget<LineChart>(find.byType(LineChart)).data;

    final points = [
      entry(60, DateTime(2026, 1, 1)),
      entry(70, DateTime(2026, 1, 2)),
    ];

    testWidgets('singleMeasurement draws one line per given role', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl.singleMeasurement(
            points,
            'kg',
            avgs: points,
            trend: points,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(chartData(tester).lineBarsData, hasLength(3));
      expect(chartData(tester).betweenBarsData, isEmpty);
    });

    testWidgets('omits the lines it was not given', (tester) async {
      await tester.pumpWidget(
        _wrap(MeasurementChartWidgetFl.singleMeasurement(points, 'kg')),
      );
      await tester.pumpAndSettle();

      expect(chartData(tester).lineBarsData, hasLength(1));
    });

    testWidgets('draws one line per component, in distinct colours', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl([
            MeasurementChartSeries(points, MeasurementSeriesRole.component, label: 'Systolic'),
            MeasurementChartSeries(points, MeasurementSeriesRole.component, label: 'Diastolic'),
          ], 'mmHg'),
        ),
      );
      await tester.pumpAndSettle();

      final bars = chartData(tester).lineBarsData;
      expect(bars, hasLength(2));
      expect(bars.first.color, isNot(bars.last.color));
    });

    testWidgets('a range series adds a band between two invisible bounds', (tester) async {
      final ranged = [
        MeasurementChartEntry(60, DateTime(2026, 1, 1), min: 50, max: 80),
        MeasurementChartEntry(70, DateTime(2026, 1, 2), min: 55, max: 95),
      ];
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl([
            MeasurementChartSeries(ranged, MeasurementSeriesRole.raw),
          ], 'bpm'),
        ),
      );
      await tester.pumpAndSettle();

      final data = chartData(tester);
      // lower bound, upper bound, and the line itself
      expect(data.lineBarsData, hasLength(3));
      expect(data.betweenBarsData, hasLength(1));
      expect(data.betweenBarsData.single.fromIndex, 0);
      expect(data.betweenBarsData.single.toIndex, 1);
      // the bounds carry the range, not the value
      expect(data.lineBarsData[0].spots.map((s) => s.y), [50, 55]);
      expect(data.lineBarsData[1].spots.map((s) => s.y), [80, 95]);
      expect(data.lineBarsData[2].spots.map((s) => s.y), [60, 70]);
    });

    testWidgets('no band when only some points carry a range', (tester) async {
      await tester.pumpWidget(
        _wrap(
          MeasurementChartWidgetFl([
            MeasurementChartSeries([
              MeasurementChartEntry(60, DateTime(2026, 1, 1), min: 50, max: 80),
              entry(70, DateTime(2026, 1, 2)),
            ], MeasurementSeriesRole.raw),
          ], 'bpm'),
        ),
      );
      await tester.pumpAndSettle();

      expect(chartData(tester).betweenBarsData, isEmpty);
      expect(chartData(tester).lineBarsData, hasLength(1));
    });
  });

  group('aggregatePerDay', () {
    test('returns an empty list for no entries', () {
      expect(aggregatePerDay([]), isEmpty);
    });

    test('sums entries sharing a calendar day into one point', () {
      final result = aggregatePerDay([
        entry(1000, DateTime(2026, 1, 1, 8)),
        entry(2500, DateTime(2026, 1, 1, 20)),
      ]);

      expect(result.length, 1);
      expect(result.single.value, 3500);
      // time-of-day is stripped to the day boundary
      expect(result.single.date, DateTime(2026, 1, 1));
    });

    test('keeps separate days apart and sorts them ascending', () {
      final result = aggregatePerDay([
        entry(30, DateTime(2026, 1, 3)),
        entry(10, DateTime(2026, 1, 1, 6)),
        entry(5, DateTime(2026, 1, 1, 23)),
        entry(20, DateTime(2026, 1, 2)),
      ]);

      expect(result.map((e) => e.date), [
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 3),
      ]);
      expect(result.map((e) => e.value), [15, 20, 30]);
    });
  });

  group('smoothedTrendline', () {
    test('returns an empty list for no entries', () {
      expect(smoothedTrendline([]), isEmpty);
    });

    test('seeds the first point with the raw value and keeps the dates', () {
      final input = [
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 2)),
        entry(30, DateTime(2026, 1, 3)),
      ];
      final result = smoothedTrendline(input, period: 10);

      expect(result.length, 3);
      expect(result.first.value, 10); // seed == first raw value
      expect(result.map((e) => e.date), input.map((e) => e.date));
    });

    test('EMA follows a rising series but lags behind the raw values', () {
      final result = smoothedTrendline([
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 2)),
        entry(30, DateTime(2026, 1, 3)),
      ], period: 10);

      // smoothing k = 2 / (10 + 1) ~= 0.1818
      // point 2: 20*k + 10*(1-k) = 11.818...
      expect(result[1].value, closeTo(11.818, 0.001));
      // point 3: 30*k + 11.818*(1-k) = 15.123...
      expect(result[2].value, closeTo(15.123, 0.001));
      // trend trails the raw climb
      expect(result[2].value, lessThan(30));
    });

    test('sorts unordered input by date before smoothing', () {
      final result = smoothedTrendline([
        entry(30, DateTime(2026, 1, 3)),
        entry(10, DateTime(2026, 1, 1)),
        entry(20, DateTime(2026, 1, 2)),
      ], period: 10);

      expect(result.first.date, DateTime(2026, 1, 1));
      expect(result.first.value, 10);
      expect(result.last.date, DateTime(2026, 1, 3));
    });
  });
}
