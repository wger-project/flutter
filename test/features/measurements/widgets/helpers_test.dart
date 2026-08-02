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
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/widgets/charts.dart';
import 'package:wger/features/measurements/widgets/helpers.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

Widget _wrapChart(Widget chart) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SizedBox(width: 400, height: 300, child: chart),
  ),
);

/// Pumps a MaterialApp whose body is the widget list built by [builder].
Future<void> _pumpWidgetList(
  WidgetTester tester,
  List<Widget> Function(BuildContext context) builder,
) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (ctx) => Scaffold(
          body: SingleChildScrollView(child: Column(children: builder(ctx))),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final rawEntries = [
    MeasurementChartEntry(10, DateTime(2026, 1, 1)),
    MeasurementChartEntry(20, DateTime(2026, 1, 10)),
  ];
  final avgEntries = moving7dAverage(rawEntries);

  group('chartEntriesFor', () {
    test('converts the aggregate bounds along with the value', () {
      // Reading the value in lb but the bounds in kg would put the band a
      // factor 2.2 off the line it is supposed to wrap
      final points = chartEntriesFor(
        [
          MeasurementEntry(
            categoryId: 'c',
            date: DateTime(2026, 1, 1),
            value: 80,
            notes: '',
            extraData: const {'min': 70, 'max': 90},
          ),
        ],
        targetUnit: 'lb',
        categoryUnit: 'kg',
      );

      expect(points.single.value, 176.37);
      expect(points.single.min, 154.32);
      expect(points.single.max, 198.42);
    });

    test('leaves entries without bounds unranged', () {
      final points = chartEntriesFor(
        [
          MeasurementEntry(
            categoryId: 'c',
            date: DateTime(2026, 1, 1),
            value: 80,
            notes: '',
          ),
        ],
        targetUnit: 'kg',
        categoryUnit: 'kg',
      );

      expect(points.single.hasRange, isFalse);
    });
  });

  group('buildChartForMetricType routing', () {
    final entries = [
      MeasurementChartEntry(1000, DateTime(2026, 1, 1)),
      MeasurementChartEntry(2000, DateTime(2026, 1, 2)),
    ];

    testWidgets('steps -> MeasurementBarChartWidgetFl', (tester) async {
      final widget = buildChartForMetricType(MetricType.steps, entries, [], 'steps');
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementBarChartWidgetFl), findsOneWidget);
      expect(find.byType(MeasurementChartWidgetFl), findsNothing);
    });

    testWidgets('custom -> MeasurementChartWidgetFl', (tester) async {
      final widget = buildChartForMetricType(MetricType.custom, entries, [], 'cm');
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);
      expect(find.byType(MeasurementBarChartWidgetFl), findsNothing);
    });

    testWidgets('a condensed history draws one band, around the values', (tester) async {
      // Past ~200 points both the values and their average are condensed, and
      // condensing attaches a range to every point. Only the values may be
      // given a band; the average must not get a second one.
      final many = [
        for (var i = 0; i < 400; i++)
          MeasurementChartEntry(60 + i % 7, DateTime(2026, 1, 1).add(Duration(days: i))),
      ];
      final widget = buildChartForMetricType(
        MetricType.custom,
        many,
        moving7dAverage(many),
        'kg',
      );
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      final data = tester.widget<LineChart>(find.byType(LineChart)).data;
      expect(data.betweenBarsData, hasLength(1));
    });

    testWidgets('energy -> MeasurementBarChartWidgetFl', (tester) async {
      final widget = buildChartForMetricType(MetricType.energy, entries, [], 'kcal');
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementBarChartWidgetFl), findsOneWidget);
    });
  });

  group('group charts', () {
    MeasurementEntry entry(String categoryId, DateTime date, num value) =>
        MeasurementEntry(categoryId: categoryId, date: date, value: value, notes: '');

    /// A sleep group as the importer writes it: the total plus its stages.
    MeasurementCategory sleepGroup({bool withStages = true}) => MeasurementCategory(
      id: 'g',
      name: 'Sleep',
      unit: 'min',
      metricType: MetricType.sleep,
      children: [
        MeasurementCategory(
          id: 'total',
          name: 'Total sleep',
          unit: 'min',
          metricType: MetricType.sleepTotal,
          parentId: 'g',
          entries: [entry('total', DateTime(2026, 1, 2), 480)],
        ),
        MeasurementCategory(
          id: 'deep',
          name: 'Deep sleep',
          unit: 'min',
          metricType: MetricType.sleepDeep,
          parentId: 'g',
          order: 1,
          entries: withStages ? [entry('deep', DateTime(2026, 1, 2), 90)] : const [],
        ),
        MeasurementCategory(
          id: 'rem',
          name: 'REM sleep',
          unit: 'min',
          metricType: MetricType.sleepRem,
          parentId: 'g',
          order: 2,
          entries: withStages ? [entry('rem', DateTime(2026, 1, 2), 60)] : const [],
        ),
      ],
    );

    MeasurementCategory bloodPressure() => MeasurementCategory(
      id: 'bp',
      name: 'Blood pressure',
      unit: 'mmHg',
      metricType: MetricType.bloodPressure,
      children: [
        MeasurementCategory(
          id: 'sys',
          name: 'Systolic',
          unit: 'mmHg',
          metricType: MetricType.bloodPressureSystolic,
          parentId: 'bp',
          entries: [entry('sys', DateTime(2026, 1, 2, 8), 120)],
        ),
        MeasurementCategory(
          id: 'dia',
          name: 'Diastolic',
          unit: 'mmHg',
          metricType: MetricType.bloodPressureDiastolic,
          parentId: 'bp',
          order: 1,
          entries: [entry('dia', DateTime(2026, 1, 2, 8), 80)],
        ),
      ],
    );

    test('the roll-up component is left out of the stack', () {
      // Total sleep covers the stages, so stacking it would count the night
      // twice
      expect(
        stackableComponents(sleepGroup()).map((c) => c.metricType),
        [MetricType.sleepDeep, MetricType.sleepRem],
      );
      expect(stackableComponents(bloodPressure()), hasLength(2));
    });

    test('stacked entries carry one value per component and day', () {
      final components = stackableComponents(sleepGroup());
      final stacked = groupStackedEntries(components);

      expect(stacked, hasLength(1));
      expect(stacked.single.date, DateTime(2026, 1, 2));
      expect(stacked.single.values, [90, 60]);
      expect(stacked.single.total, 150);
    });

    test('several entries of one day add up within their component', () {
      // A nap next to the night: the bar shows the day, not the segment
      final group = MeasurementCategory(
        id: 'g',
        name: 'Sleep',
        unit: 'min',
        metricType: MetricType.sleep,
        children: [
          MeasurementCategory(
            id: 'deep',
            name: 'Deep sleep',
            unit: 'min',
            metricType: MetricType.sleepDeep,
            parentId: 'g',
            entries: [
              entry('deep', DateTime(2026, 1, 2, 3), 90),
              entry('deep', DateTime(2026, 1, 2, 14), 20),
            ],
          ),
        ],
      );

      expect(groupStackedEntries(group.children).single.values, [110]);
    });

    test('readings pair the components on their shared timestamp', () {
      final readings = groupReadings(bloodPressure());

      expect(readings, hasLength(1));
      expect(readings.single.$1, DateTime(2026, 1, 2, 8));
      expect(readings.single.$2, {'Systolic': 120, 'Diastolic': 80});
    });

    testWidgets('a summed group stacks its components', (tester) async {
      await tester.pumpWidget(
        _wrapChart(Builder(builder: (ctx) => buildGroupChart(ctx, sleepGroup()))),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementStackedBarChartWidgetFl), findsOneWidget);
    });

    testWidgets('a two-component group is a floating bar per reading', (tester) async {
      await tester.pumpWidget(
        _wrapChart(Builder(builder: (ctx) => buildGroupChart(ctx, bloodPressure()))),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementBarChartWidgetFl), findsOneWidget);
      expect(find.byType(MeasurementStackedBarChartWidgetFl), findsNothing);
    });

    testWidgets('without stage data the group falls back to lines', (tester) async {
      // Only the total reported, so there is nothing to stack. Falling through
      // to the line chart keeps the card from going blank while data exists
      await tester.pumpWidget(
        _wrapChart(
          Builder(builder: (ctx) => buildGroupChart(ctx, sleepGroup(withStages: false))),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementStackedBarChartWidgetFl), findsNothing);
      expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);
    });
  });

  group('getOverviewWidgets', () {
    testWidgets('empty raw shows no-data placeholder', (tester) async {
      await _pumpWidgetList(tester, (ctx) => getOverviewWidgets('Test', [], [], 'cm', ctx));

      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('non-empty avg includes MeasurementOverallChangeWidget', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => getOverviewWidgets('Test', rawEntries, avgEntries, 'cm', ctx),
      );

      expect(find.byType(MeasurementOverallChangeWidget), findsOneWidget);
    });
  });

  group('getOverviewWidgetsSeries legend', () {
    testWidgets('three Indicator widgets for non-summed metric (custom)', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => getOverviewWidgetsSeries(
          'Weight',
          rawEntries,
          avgEntries,
          [],
          'kg',
          ctx,
          metricType: MetricType.custom,
        ),
      );

      expect(find.byType(Indicator), findsNWidgets(3));
    });

    testWidgets('two Indicator widgets for summed metric (steps, no trend)', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => getOverviewWidgetsSeries(
          'Steps',
          rawEntries,
          avgEntries,
          [],
          'steps',
          ctx,
          metricType: MetricType.steps,
        ),
      );

      // isSummedPerDay -> trend indicator is hidden
      expect(find.byType(Indicator), findsNWidgets(2));
    });

    testWidgets('plan periods add their own indicator', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => getOverviewWidgetsSeries(
          'Weight',
          rawEntries,
          avgEntries,
          [
            (
              range: DateTimeRange(start: DateTime(2026, 1, 2), end: DateTime(2026, 1, 5)),
              name: 'Cut',
            ),
          ],
          'kg',
          ctx,
          metricType: MetricType.custom,
        ),
      );

      expect(find.byType(Indicator), findsNWidgets(4));
    });
  });

  group('getOverviewWidgetsSeries 30-day chart', () {
    testWidgets('trend is the tail of the full-history trend', (tester) async {
      // A history long enough to trigger the extra 30-day chart. Its trend
      // must be the sliced full-history trend, not an EMA restarted (and
      // seeded) at the window's first point.
      final history = [
        for (var i = 0; i < 100; i++)
          MeasurementChartEntry(
            60 + (i % 5),
            DateTime.now().subtract(Duration(days: 99 - i, hours: 1)),
          ),
      ];
      await _pumpWidgetList(
        tester,
        (ctx) =>
            getOverviewWidgetsSeries('Weight', history, moving7dAverage(history), [], 'kg', ctx),
      );

      final charts = tester.widgetList<LineChart>(find.byType(LineChart)).toList();
      expect(charts, hasLength(2));

      // series order is raw, average, trend
      List<FlSpot> trendOf(LineChart chart) => chart.data.lineBarsData[2].spots;
      final mainTrend = trendOf(charts.first).map((s) => (s.x, s.y)).toSet();
      final windowTrend = trendOf(charts.last);

      expect(windowTrend, isNotEmpty);
      expect(windowTrend.length, lessThan(mainTrend.length));
      for (final spot in windowTrend) {
        expect(mainTrend, contains((spot.x, spot.y)));
      }
    });
  });

  group('getOverviewWidgetsSeries plan periods', () {
    testWidgets('one chart with bands instead of one chart per plan', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => getOverviewWidgetsSeries(
          'Weight',
          rawEntries,
          avgEntries,
          [
            (
              range: DateTimeRange(start: DateTime(2026, 1, 2), end: DateTime(2026, 1, 5)),
              name: 'Cut',
            ),
            (
              range: DateTimeRange(start: DateTime(2026, 2, 1), end: DateTime(2026, 2, 10)),
              name: 'Bulk',
            ),
          ],
          'kg',
          ctx,
          metricType: MetricType.custom,
        ),
      );

      // the history is short, so there is no 30-day chart either
      expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);
      final data = tester.widget<LineChart>(find.byType(LineChart)).data;
      // only the february plan misses the data range
      expect(data.rangeAnnotations.verticalRangeAnnotations, hasLength(1));
    });
  });
}
