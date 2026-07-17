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
