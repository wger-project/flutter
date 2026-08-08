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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/providers/measurement_repository.dart';
import 'package:wger/features/measurements/screens/measurement_entries_screen.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/features/measurements/widgets/measurement_tile.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../helpers/measurement_chart_buckets.dart';
import '../../../helpers/measurement_repository_stubs.dart';
import 'measurement_tile_test.mocks.dart';

/// The calendar day [daysAgo] days back, at midnight like a day bucket.
DateTime _day(int daysAgo) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - daysAgo);
}

MeasurementEntry _entry(String categoryId, num value, DateTime date, {String source = 'user'}) =>
    MeasurementEntry(
      id: '$categoryId-$date',
      categoryId: categoryId,
      date: date,
      value: value,
      notes: '',
      source: source,
    );

Widget _wrap(
  MeasurementCategory category, {
  List<MeasurementCategory> categories = const [],
  Map<String, List<MeasurementEntry>> entries = const {},
  ChartRange range = ChartRange.last3Months,
}) {
  final mockRepo = MockMeasurementRepository();
  stubMeasurementReads(mockRepo, categories.isEmpty ? [category] : categories, entries);

  return ProviderScope(
    overrides: [
      measurementRepositoryProvider.overrideWithValue(mockRepo),
      measurementChartBucketsProvider.overrideWith(chartBucketsFrom(entries)),
      measurementGroupBucketsProvider.overrideWith(
        groupBucketsFrom(categories.isEmpty ? [category] : categories, entries),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        MeasurementEntriesScreen.routeName: (_) => const Text('entries-screen'),
      },
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 180,
            height: measurementTileExtent,
            child: MeasurementTile(category, range: range),
          ),
        ),
      ),
    ),
  );
}

@GenerateMocks([MeasurementRepository])
void main() {
  final restingHeartRate = MeasurementCategory(
    id: 'rhr',
    name: 'Resting heart rate',
    unit: 'bpm',
    metricType: MetricType.restingHeartRate,
  );

  group('MeasurementTile', () {
    testWidgets('daily tile: latest value, weekday axis and a stable trend', (tester) async {
      final entries = {
        'rhr': [for (var day = 6; day >= 0; day--) _entry('rhr', 61, _day(day))],
      };

      await tester.pumpWidget(_wrap(restingHeartRate, entries: entries));
      await tester.pumpAndSettle();

      expect(find.text('Resting heart rate'), findsOneWidget);
      expect(find.text('61 bpm'), findsOneWidget);
      expect(find.byType(SparkLineChart), findsOneWidget);
      expect(find.textContaining('stable'), findsOneWidget);
    });

    testWidgets('a moving value quotes its weekly rate instead', (tester) async {
      final entries = {
        'rhr': [for (var day = 6; day >= 0; day--) _entry('rhr', 70 - day * 2, _day(day))],
      };

      await tester.pumpWidget(_wrap(restingHeartRate, entries: entries));
      await tester.pumpAndSettle();

      expect(find.textContaining('/week'), findsOneWidget);
      expect(find.textContaining('↗'), findsOneWidget);
    });

    testWidgets('sparse tile: dots, months and the last-measured date', (tester) async {
      final lastMeasured = _day(21);
      final entries = {
        'biceps': [_entry('biceps', 38.5, lastMeasured)],
      };
      final biceps = MeasurementCategory(id: 'biceps', name: 'Biceps', unit: 'cm');

      await tester.pumpWidget(_wrap(biceps, entries: entries));
      await tester.pumpAndSettle();

      expect(find.text('38.5 cm'), findsOneWidget);
      final dots = tester.widget<SparkLineChart>(find.byType(SparkLineChart));
      expect(dots.dots, isTrue);
      expect(find.text(DateFormat.yMd('en').format(lastMeasured)), findsOneWidget);
    });

    testWidgets('summed tile: bars and the window average', (tester) async {
      final steps = MeasurementCategory(
        id: 'steps',
        name: 'Steps',
        metricType: MetricType.steps,
      );
      final entries = {
        'steps': [_entry('steps', 8000, _day(1)), _entry('steps', 6000, _day(2))],
      };

      await tester.pumpWidget(_wrap(steps, entries: entries));
      await tester.pumpAndSettle();

      expect(find.byType(SparkBarChart), findsOneWidget);
      expect(find.textContaining('avg'), findsOneWidget);
    });

    testWidgets('the range filter decides between daily and weekly slots', (tester) async {
      final steps = MeasurementCategory(
        id: 'steps',
        name: 'Steps',
        metricType: MetricType.steps,
      );
      final entries = {
        'steps': [_entry('steps', 8000, _day(1)), _entry('steps', 6000, _day(2))],
      };

      // A week is seven daily slots and a month one per day; three months
      // come as calendar weeks
      await tester.pumpWidget(_wrap(steps, entries: entries, range: ChartRange.lastWeek));
      await tester.pumpAndSettle();
      var chart = tester.widget<SparkBarChart>(find.byType(SparkBarChart));
      expect(chart.data.slotCount, 7);

      await tester.pumpWidget(_wrap(steps, entries: entries, range: ChartRange.lastMonth));
      await tester.pumpAndSettle();
      chart = tester.widget<SparkBarChart>(find.byType(SparkBarChart));
      expect(chart.data.slotCount, 31);

      await tester.pumpWidget(_wrap(steps, entries: entries, range: ChartRange.last3Months));
      await tester.pumpAndSettle();
      chart = tester.widget<SparkBarChart>(find.byType(SparkBarChart));
      expect(chart.data.slotCount, 13);
    });

    testWidgets('blood pressure tile: the reading quoted high over low', (tester) async {
      final group = MeasurementCategory(
        id: 'bp',
        name: 'Blood pressure',
        unit: 'mmHg',
        metricType: MetricType.bloodPressure,
        children: [
          MeasurementCategory(id: 'sys', name: 'Systolic', unit: 'mmHg', parentId: 'bp'),
          MeasurementCategory(id: 'dia', name: 'Diastolic', unit: 'mmHg', parentId: 'bp'),
        ],
      );
      final entries = {
        'sys': [_entry('sys', 122, _day(0))],
        'dia': [_entry('dia', 79, _day(0))],
      };

      await tester.pumpWidget(
        _wrap(group, categories: [group, ...group.children], entries: entries),
      );
      await tester.pumpAndSettle();

      expect(find.text('122/79 mmHg'), findsOneWidget);
      expect(find.byType(SparkBarChart), findsOneWidget);
    });

    testWidgets('sleep tile: the total leads, stacked bars behind it', (tester) async {
      final group = MeasurementCategory(
        id: 'sleep',
        name: 'Sleep',
        unit: 'min',
        metricType: MetricType.sleep,
        children: [
          MeasurementCategory(
            id: 'total',
            name: 'Total sleep',
            unit: 'min',
            metricType: MetricType.sleepTotal,
            parentId: 'sleep',
          ),
          MeasurementCategory(
            id: 'deep',
            name: 'Deep sleep',
            unit: 'min',
            metricType: MetricType.sleepDeep,
            parentId: 'sleep',
          ),
        ],
      );
      final entries = {
        'total': [_entry('total', 432, _day(1))],
        'deep': [_entry('deep', 90, _day(1))],
      };

      await tester.pumpWidget(
        _wrap(group, categories: [group, ...group.children], entries: entries),
      );
      await tester.pumpAndSettle();

      expect(find.text('7:12 h'), findsOneWidget);
      expect(find.byType(SparkBarChart), findsOneWidget);
    });

    testWidgets('heatmap tile: the grid plus the footer of its kind', (tester) async {
      final steps = MeasurementCategory(
        id: 'steps',
        name: 'Steps',
        metricType: MetricType.steps,
        chartType: ChartType.heatmap,
      );
      final entries = {
        'steps': [_entry('steps', 8000, _day(1)), _entry('steps', 6000, _day(2))],
      };

      await tester.pumpWidget(_wrap(steps, entries: entries));
      await tester.pumpAndSettle();

      final heatmap = tester.widget<SparkHeatmap>(find.byType(SparkHeatmap));
      // Three months of filter come as 13 week columns
      expect(heatmap.weeks, 13);
      expect(find.textContaining('avg'), findsOneWidget);
    });

    testWidgets('the hero rounds to the decimals the type is measured at', (tester) async {
      // A pulse has no meaningful tenths; the stored value stays exact and is
      // shown in full on the detail screens
      final entries = {
        'rhr': [_entry('rhr', 61.44, _day(0))],
      };

      await tester.pumpWidget(_wrap(restingHeartRate, entries: entries));
      await tester.pumpAndSettle();

      expect(find.text('61 bpm'), findsOneWidget);
    });

    testWidgets('a tile without entries still stands, value dashed out', (tester) async {
      await tester.pumpWidget(_wrap(restingHeartRate));
      await tester.pumpAndSettle();

      expect(find.text('— bpm'), findsOneWidget);
    });

    testWidgets('tapping the tile opens the entries screen', (tester) async {
      final entries = {
        'rhr': [_entry('rhr', 61, _day(0))],
      };

      await tester.pumpWidget(_wrap(restingHeartRate, entries: entries));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MeasurementTile));
      await tester.pumpAndSettle();

      expect(find.text('entries-screen'), findsOneWidget);
    });
  });
}
