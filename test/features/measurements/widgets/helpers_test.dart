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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/core/widgets/legend.dart';
import 'package:wger/features/measurements/charts/data.dart';
import 'package:wger/features/measurements/charts/series.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/widgets/charts/bar_chart.dart';
import 'package:wger/features/measurements/widgets/charts/distribution_chart.dart';
import 'package:wger/features/measurements/widgets/charts/heatmap_chart.dart';
import 'package:wger/features/measurements/widgets/charts/line_chart.dart';
import 'package:wger/features/measurements/widgets/charts/overall_change.dart';
import 'package:wger/features/measurements/widgets/charts/stacked_bar_chart.dart';
import 'package:wger/features/measurements/widgets/helpers.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../helpers/measurement_chart_buckets.dart';

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
  final avgEntries = movingAverage(rawEntries);

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
      // Condensed points carry the range they stand for, and the average
      // derived from them inherits it. Only the values may be given a band;
      // the average must not get a second one.
      final many = [
        for (var i = 0; i < 40; i++)
          MeasurementChartEntry(
            60 + i % 7,
            DateTime(2026, 1, 1).add(Duration(days: i)),
            min: 55,
            max: 70,
          ),
      ];
      final widget = buildChartForMetricType(
        MetricType.custom,
        many,
        movingAverage(many),
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

    testWidgets('a heatmap override wins over the derived chart', (tester) async {
      final widget = buildChartForMetricType(
        MetricType.steps,
        entries,
        [],
        'steps',
        chartType: ChartType.heatmap,
      );
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementHeatmapWidgetFl), findsOneWidget);
      expect(find.byType(MeasurementBarChartWidgetFl), findsNothing);
    });

    testWidgets('a sample type keeps its line chart under a bar override', (tester) async {
      // Bars are not offered for a sample type, and a value that does not fit
      // falls back to the derived chart instead of being drawn anyway
      final widget = buildChartForMetricType(
        MetricType.custom,
        entries,
        [],
        'cm',
        chartType: ChartType.bar,
      );
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);
    });

    testWidgets('a delta override draws the weekly changes as signed bars', (tester) async {
      // 5 January 2026 is a Monday
      final weekly = [
        MeasurementChartEntry(80, DateTime(2026, 1, 5)),
        MeasurementChartEntry(79, DateTime(2026, 1, 12)),
        MeasurementChartEntry(79.5, DateTime(2026, 1, 19)),
      ];
      final widget = buildChartForMetricType(
        MetricType.bodyWeight,
        weekly,
        [],
        'kg',
        chartType: ChartType.delta,
      );
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementChartWidgetFl), findsNothing);
      final rods = tester
          .widget<BarChart>(find.byType(BarChart))
          .data
          .barGroups
          .map((g) => g.barRods.single);
      expect(rods.map((r) => r.toY), [-1, 0.5]);
      expect(rods.first.color, isNot(rods.last.color));
    });

    testWidgets('a distribution override bins the values instead of plotting them', (tester) async {
      final history = [
        for (var i = 0; i < 30; i++) MeasurementChartEntry(80 + (i % 5), DateTime(2026, 1, 1 + i)),
      ];
      final widget = buildChartForMetricType(
        MetricType.bodyWeight,
        history,
        [],
        'kg',
        chartType: ChartType.distribution,
        // Built by the caller, which is where the counted values are read
        distribution: MeasurementDistributionWidgetFl(
          [for (final point in history) (value: point.value, count: 1)],
          latest: history.last.value,
          unit: 'kg',
        ),
      );
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementChartWidgetFl), findsNothing);
      expect(find.byType(MeasurementDistributionWidgetFl), findsOneWidget);
    });

    testWidgets('a distribution of too few values falls back to the derived chart', (tester) async {
      // A histogram of a handful of values is noise with gaps, so the card
      // shows the default chart instead of an empty-looking one
      final widget = buildChartForMetricType(
        MetricType.bodyWeight,
        [for (var i = 0; i < 5; i++) MeasurementChartEntry(80, DateTime(2026, 1, 1 + i))],
        [],
        'kg',
        chartType: ChartType.distribution,
      );
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementDistributionWidgetFl), findsNothing);
      expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);
    });

    testWidgets('condensed points are counted by what they stand for', (tester) async {
      // A hundred weigh-ins around one number are a distribution, however few
      // points they were condensed into
      final widget = buildChartForMetricType(
        MetricType.bodyWeight,
        [
          for (var i = 0; i < 5; i++)
            MeasurementChartEntry(80, DateTime(2026, 1, 1 + i), count: 20),
        ],
        [],
        'kg',
        chartType: ChartType.distribution,
        distribution: const MeasurementDistributionWidgetFl(
          [(value: 80, count: 100)],
          latest: 80,
          unit: 'kg',
        ),
      );
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementDistributionWidgetFl), findsOneWidget);
    });

    testWidgets('a summed distribution measures its days, not its samples', (tester) async {
      // 30 samples on 5 days are 5 daily totals: not enough for a histogram,
      // whatever the sample count says
      final widget = buildChartForMetricType(
        MetricType.steps,
        [
          for (var i = 0; i < 30; i++)
            MeasurementChartEntry(500, DateTime(2026, 1, 1 + i % 5, 8 + i ~/ 5)),
        ],
        [],
        'count',
        chartType: ChartType.distribution,
      );
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementDistributionWidgetFl), findsNothing);
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('a heatmap keeps one point per day instead of condensing', (tester) async {
      // Past ~200 points the line chart condenses into calendar buckets, which
      // for a grid of days would collapse whole weeks into a single cell
      final many = [
        for (var i = 0; i < 300; i++)
          MeasurementChartEntry(60 + i % 7, DateTime(2026, 1, 1).add(Duration(days: i))),
      ];
      final widget = buildChartForMetricType(
        MetricType.custom,
        many,
        [],
        'kg',
        chartType: ChartType.heatmap,
      );
      await tester.pumpWidget(_wrapChart(widget));
      await tester.pumpAndSettle();

      final heatmap = tester.widget<MeasurementHeatmapWidgetFl>(
        find.byType(MeasurementHeatmapWidgetFl),
      );
      expect(heatmap.days, hasLength(300));
    });
  });

  group('group charts', () {
    MeasurementEntry entry(String categoryId, DateTime date, num value) =>
        MeasurementEntry(categoryId: categoryId, date: date, value: value, notes: '');

    /// A sleep group as the importer writes it: the total plus its stages.
    MeasurementCategory sleepGroup() => MeasurementCategory(
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
        ),
        MeasurementCategory(
          id: 'deep',
          name: 'Deep sleep',
          unit: 'min',
          metricType: MetricType.sleepDeep,
          parentId: 'g',
          order: 1,
        ),
        MeasurementCategory(
          id: 'rem',
          name: 'REM sleep',
          unit: 'min',
          metricType: MetricType.sleepRem,
          parentId: 'g',
          order: 2,
        ),
      ],
    );

    Map<String, List<MeasurementEntry>> sleepEntries({bool withStages = true}) => {
      'total': [entry('total', DateTime(2026, 1, 2), 480)],
      'deep': withStages ? [entry('deep', DateTime(2026, 1, 2), 90)] : const [],
      'rem': withStages ? [entry('rem', DateTime(2026, 1, 2), 60)] : const [],
    };

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
        ),
        MeasurementCategory(
          id: 'dia',
          name: 'Diastolic',
          unit: 'mmHg',
          metricType: MetricType.bloodPressureDiastolic,
          parentId: 'bp',
          order: 1,
        ),
      ],
    );

    Map<String, List<MeasurementEntry>> bloodPressureEntries() => {
      'sys': [entry('sys', DateTime(2026, 1, 2, 8), 120)],
      'dia': [entry('dia', DateTime(2026, 1, 2, 8), 80)],
    };

    /// The points the aggregated query returns for [group], which is one
    /// bucket per entry unless the metric is summed per day
    Map<String, List<MeasurementChartEntry>> pointsOf(
      MeasurementCategory group,
      Map<String, List<MeasurementEntry>> entries,
    ) => groupComponentPoints(group, {
      for (final child in group.children)
        child.id!: group.metricType.isSummedPerDay
            ? dayBuckets(entries[child.id] ?? const [])
            : entryBuckets(entries[child.id] ?? const []),
    });

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
      final stacked = groupStackedEntries(components, pointsOf(sleepGroup(), sleepEntries()));

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
          ),
        ],
      );
      final entries = {
        'deep': [
          entry('deep', DateTime(2026, 1, 2, 3), 90),
          entry('deep', DateTime(2026, 1, 2, 14), 20),
        ],
      };

      expect(groupStackedEntries(group.children, pointsOf(group, entries)).single.values, [110]);
    });

    test('readings pair the components on their shared timestamp', () {
      final group = bloodPressure();
      final readings = groupReadings(
        group,
        bloodPressureEntries().values.expand((e) => e).toList(),
      );

      expect(readings, hasLength(1));
      expect(readings.single.$1, DateTime(2026, 1, 2, 8));
      // keyed by the component id, the name is translated for display
      expect(readings.single.$2, {'sys': 120, 'dia': 80});
    });

    testWidgets('a summed group stacks its components', (tester) async {
      await tester.pumpWidget(
        _wrapChart(
          Builder(
            builder: (ctx) =>
                buildGroupChart(ctx, sleepGroup(), pointsOf(sleepGroup(), sleepEntries())),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementStackedBarChartWidgetFl), findsOneWidget);
    });

    testWidgets('a two-component group is a floating bar per reading', (tester) async {
      await tester.pumpWidget(
        _wrapChart(
          Builder(
            builder: (ctx) => buildGroupChart(
              ctx,
              bloodPressure(),
              pointsOf(bloodPressure(), bloodPressureEntries()),
            ),
          ),
        ),
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
          Builder(
            builder: (ctx) => buildGroupChart(
              ctx,
              sleepGroup(),
              pointsOf(sleepGroup(), sleepEntries(withStages: false)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MeasurementStackedBarChartWidgetFl), findsNothing);
      expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);
    });
  });

  group('buildChartSection', () {
    testWidgets('empty raw shows no-data placeholder', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => buildChartSection(ctx, title: 'Test', raw: [], avg: [], unit: 'cm'),
      );

      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('non-empty avg includes MeasurementOverallChangeWidget', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) =>
            buildChartSection(ctx, title: 'Test', raw: rawEntries, avg: avgEntries, unit: 'cm'),
      );

      expect(find.byType(MeasurementOverallChangeWidget), findsOneWidget);
    });
  });

  group('buildSeriesChartSection legend', () {
    testWidgets('three Indicator widgets for non-summed metric (custom)', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => buildSeriesChartSection(
          ctx,
          name: 'Weight',
          entriesAll: rawEntries,
          average: avgEntries,
          unit: 'kg',
          metricType: MetricType.custom,
        ),
      );

      expect(find.byType(Indicator), findsNWidgets(3));
      // The screen names the category and the range selector names the range
      expect(find.textContaining('Weight'), findsNothing);
    });

    testWidgets('two Indicator widgets for summed metric (steps, no trend)', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => buildSeriesChartSection(
          ctx,
          name: 'Steps',
          entriesAll: rawEntries,
          average: avgEntries,
          unit: 'steps',
          metricType: MetricType.steps,
        ),
      );

      // isSummedPerDay -> trend indicator is hidden
      expect(find.byType(Indicator), findsNWidgets(2));
    });

    testWidgets('plan periods add their own indicator', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => buildSeriesChartSection(
          ctx,
          name: 'Weight',
          entriesAll: rawEntries,
          average: avgEntries,
          unit: 'kg',
          planPeriods: [
            (
              range: DateTimeRange(start: DateTime(2026, 1, 2), end: DateTime(2026, 1, 5)),
              name: 'Cut',
            ),
          ],
          metricType: MetricType.custom,
        ),
      );

      expect(find.byType(Indicator), findsNWidgets(4));
    });
  });

  group('buildSeriesChartSection change chart', () {
    final history = [
      for (var i = 0; i < 100; i++)
        MeasurementChartEntry(60 + (i % 5), DateTime.now().subtract(Duration(days: 99 - i))),
    ];

    Future<void> pumpDelta(WidgetTester tester) => _pumpWidgetList(
      tester,
      (ctx) => buildSeriesChartSection(
        ctx,
        name: 'Weight',
        entriesAll: history,
        average: movingAverage(history),
        unit: 'kg',
        metricType: MetricType.bodyWeight,
        chartType: ChartType.delta,
      ),
    );

    testWidgets('one chart, without the legend of lines it does not draw', (tester) async {
      await pumpDelta(tester);

      expect(find.byType(BarChart), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
      expect(find.byType(Indicator), findsNothing);
    });

    testWidgets('the title says the bars are changes, not values', (tester) async {
      await pumpDelta(tester);

      expect(find.text('Weight, change per week'), findsOneWidget);
    });

    testWidgets('keeps the overall change, the one-number version of it', (tester) async {
      await pumpDelta(tester);

      expect(find.byType(MeasurementOverallChangeWidget), findsOneWidget);
    });
  });

  group('buildSeriesChartSection distribution chart', () {
    final history = [
      for (var i = 0; i < 100; i++)
        MeasurementChartEntry(60 + (i % 5), DateTime.now().subtract(Duration(days: 99 - i))),
    ];

    Future<void> pumpDistribution(WidgetTester tester) => _pumpWidgetList(
      tester,
      (ctx) => buildSeriesChartSection(
        ctx,
        name: 'Weight',
        entriesAll: history,
        average: movingAverage(history),
        unit: 'kg',
        metricType: MetricType.bodyWeight,
        chartType: ChartType.distribution,
        // Built by the caller, which is where the counted values are read
        distribution: MeasurementDistributionWidgetFl(
          [for (final point in history) (value: point.value, count: 1)],
          latest: history.last.value,
          unit: 'kg',
        ),
      ),
    );

    testWidgets('one histogram, without the legend of lines it does not draw', (tester) async {
      await pumpDistribution(tester);

      expect(find.byType(MeasurementDistributionWidgetFl), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
      expect(find.byType(Indicator), findsNothing);
    });

    testWidgets('the title says the bars are a distribution, not a history', (tester) async {
      await pumpDistribution(tester);

      expect(find.text('Weight, distribution'), findsOneWidget);
    });

    testWidgets('no overall change: a distribution has no direction', (tester) async {
      await pumpDistribution(tester);

      expect(find.byType(MeasurementOverallChangeWidget), findsNothing);
    });

    testWidgets('too few values fall back to the usual line chart', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => buildSeriesChartSection(
          ctx,
          name: 'Weight',
          entriesAll: history.take(5).toList(),
          average: movingAverage(history.take(5).toList()),
          unit: 'kg',
          metricType: MetricType.bodyWeight,
          chartType: ChartType.distribution,
        ),
      );

      expect(find.byType(MeasurementDistributionWidgetFl), findsNothing);
      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('Weight, distribution'), findsNothing);
    });
  });

  group('buildSeriesChartSection plan periods', () {
    testWidgets('one chart with bands instead of one chart per plan', (tester) async {
      await _pumpWidgetList(
        tester,
        (ctx) => buildSeriesChartSection(
          ctx,
          name: 'Weight',
          entriesAll: rawEntries,
          average: avgEntries,
          unit: 'kg',
          planPeriods: [
            (
              range: DateTimeRange(start: DateTime(2026, 1, 2), end: DateTime(2026, 1, 5)),
              name: 'Cut',
            ),
            (
              range: DateTimeRange(start: DateTime(2026, 2, 1), end: DateTime(2026, 2, 10)),
              name: 'Bulk',
            ),
          ],
          metricType: MetricType.custom,
        ),
      );

      expect(find.byType(MeasurementChartWidgetFl), findsOneWidget);
      final data = tester.widget<LineChart>(find.byType(LineChart)).data;
      // only the february plan misses the data range
      expect(data.rangeAnnotations.verticalRangeAnnotations, hasLength(1));
    });
  });
}
