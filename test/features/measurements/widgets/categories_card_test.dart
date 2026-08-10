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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/models/measurement_category.dart';
import 'package:wger/features/measurements/models/measurement_entry.dart';
import 'package:wger/features/measurements/providers/measurement_notifier.dart';
import 'package:wger/features/measurements/widgets/categories_card.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../test_data/measurements.dart';
import '../../../helpers/measurement_chart_buckets.dart';

/// A category and the entries it holds, which it no longer carries itself.
typedef _Seed = ({MeasurementCategory category, Map<String, List<MeasurementEntry>> entries});

Widget _wrap(
  Widget child, {
  Map<String, MeasurementEntry> latest = const {},
  List<MeasurementCategory> categories = const [],
  Map<String, List<MeasurementEntry>> entries = const {},
}) => ProviderScope(
  overrides: [
    // The component rows read their last known value from its own query
    latestMeasurementEntriesProvider.overrideWith((ref) => Stream.value(latest)),
    // The chart reads its points from the aggregated query
    measurementChartBucketsProvider.overrideWith(chartBucketsFrom(entries)),
    measurementGroupBucketsProvider.overrideWith(groupBucketsFrom(categories, entries)),
  ],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  ),
);

/// The newest entry per category, i.e. what the query behind the rows returns
Map<String, MeasurementEntry> _latestOf(Map<String, List<MeasurementEntry>> entries) => {
  for (final MapEntry(key: id, value: ofCategory) in entries.entries)
    if (ofCategory.isNotEmpty) id: ofCategory.first,
};

/// The fixtures have fixed dates, so the card charts the full history instead
/// of the range it defaults to
Widget _card(_Seed seed) => _wrap(
  CategoriesCard(seed.category, range: ChartRange.all),
  latest: _latestOf(seed.entries),
  categories: [seed.category],
  entries: seed.entries,
);

_Seed _bpGroup({bool withEntries = false}) => (
  category: testMeasurementCategoryBloodPressure,
  entries: withEntries ? getBloodPressureEntries() : const {},
);

/// A group with three components, which cannot be read as a low/high range
_Seed _tripleGroup() {
  final children = [
    for (var i = 0; i < 3; i++)
      MeasurementCategory(
        id: 'c$i',
        name: 'Component $i',
        unit: 'mmHg',
        parentId: 'bp',
        order: i,
      ),
  ];

  return (
    category: testMeasurementCategoryBloodPressure.copyWith(children: children),
    entries: {
      for (final (i, child) in children.indexed)
        child.id!: [
          MeasurementEntry(
            id: 'e$i',
            categoryId: child.id!,
            date: DateTime(2026, 1, 1),
            value: 100 + i * 10,
            notes: '',
          ),
        ],
    },
  );
}

/// A sleep group: the total plus two stages, all on the same night
_Seed _sleepGroup() {
  MeasurementCategory child(String id, String name, MetricType type, int order) =>
      MeasurementCategory(
        id: id,
        name: name,
        unit: 'min',
        metricType: type,
        parentId: 'sleep',
        order: order,
      );

  MeasurementEntry reading(String id, num value) => MeasurementEntry(
    id: 'e-$id',
    categoryId: id,
    date: DateTime(2026, 1, 2),
    value: value,
    notes: '',
  );

  return (
    category: MeasurementCategory(
      id: 'sleep',
      name: 'Sleep',
      unit: 'min',
      metricType: MetricType.sleep,
      children: [
        child('total', 'Total sleep', MetricType.sleepTotal, 0),
        child('deep', 'Deep sleep', MetricType.sleepDeep, 1),
        child('rem', 'REM sleep', MetricType.sleepRem, 2),
      ],
    ),
    entries: {
      'total': [reading('total', 480)],
      'deep': [reading('deep', 90)],
      'rem': [reading('rem', 60)],
    },
  );
}

void main() {
  group('CategoriesCard group card', () {
    testWidgets('shows one ListTile per child with latest reading', (tester) async {
      await tester.pumpWidget(_card(_bpGroup(withEntries: true)));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.textContaining('120'), findsOneWidget);
      expect(find.textContaining('80'), findsOneWidget);
    });

    testWidgets('shows dash when child has no entries', (tester) async {
      await tester.pumpWidget(_card(_bpGroup(withEntries: false)));
      await tester.pumpAndSettle();

      // Text('—') should appear for both children
      expect(find.text('—'), findsNWidgets(2));
    });

    testWidgets('draws a reading as one bar spanning its components', (tester) async {
      await tester.pumpWidget(_card(_bpGroup(withEntries: true)));
      await tester.pumpAndSettle();

      // One event, one bar: no line claiming values between two readings
      expect(find.byType(LineChart), findsNothing);
      final groups = tester.widget<BarChart>(find.byType(BarChart)).data.barGroups;
      expect(groups, hasLength(1));

      final rod = groups.single.barRods.single;
      expect(rod.fromY, 80); // diastolic
      expect(rod.toY, 120); // systolic
    });

    testWidgets('a range needs no per-component colour dots', (tester) async {
      await tester.pumpWidget(_card(_bpGroup(withEntries: true)));
      await tester.pumpAndSettle();

      // The ends of the bar say which is which
      expect(
        tester.widgetList<ListTile>(find.byType(ListTile)).every((t) => t.leading == null),
        isTrue,
      );
    });

    testWidgets('falls back to lines when the readings are not paired', (tester) async {
      // Editing the date of one half pulls a reading apart, and there is then
      // no range to draw. The card must still show the data it has instead of
      // going blank.
      final group = (
        category: testMeasurementCategoryBloodPressure,
        entries: {
          'sys': [testNeasurementEntry9],
          'dia': [testNeasurementEntry10.copyWith(date: DateTime(2026, 1, 1, 9, 30))],
        },
      );

      await tester.pumpWidget(_card(group));
      await tester.pumpAndSettle();

      expect(find.byType(BarChart), findsNothing);
      final data = tester.widget<LineChart>(find.byType(LineChart)).data;
      expect(data.lineBarsData, hasLength(2));
    });

    testWidgets('renders no chart while no component has readings', (tester) async {
      await tester.pumpWidget(_card(_bpGroup(withEntries: false)));
      await tester.pumpAndSettle();

      expect(find.byType(BarChart), findsNothing);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('a group of three keeps one line per component', (tester) async {
      // Only two components form a low/high range; more stay separate lines
      await tester.pumpWidget(_card(_tripleGroup()));
      await tester.pumpAndSettle();

      final data = tester.widget<LineChart>(find.byType(LineChart)).data;
      expect(data.lineBarsData, hasLength(3));

      final lineColors = data.lineBarsData.map((b) => b.color).toList();
      final dotColors = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .map((t) => ((t.leading! as Container).decoration! as BoxDecoration).color)
          .toList();
      expect(dotColors, lineColors);
    });

    testWidgets('add icon button is present on group card', (tester) async {
      await tester.pumpWidget(_card(_bpGroup()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('the group itself can be opened, like any other category', (tester) async {
      await tester.pumpWidget(_card(_bpGroup(withEntries: true)));
      await tester.pumpAndSettle();

      expect(find.text('Go to detail page'), findsOneWidget);
    });

    testWidgets('sleep stacks its stages into one bar per night', (tester) async {
      await tester.pumpWidget(_card(_sleepGroup()));
      await tester.pumpAndSettle();

      final groups = tester.widget<BarChart>(find.byType(BarChart)).data.barGroups;
      expect(groups, hasLength(1));

      // The stages stack, the total does not: it already covers them
      final rod = groups.single.barRods.single;
      expect(rod.rodStackItems.map((s) => s.toY - s.fromY), [90, 60]);
      expect(rod.toY, 150);
    });

    testWidgets('a duration row reads h:mm, not minutes', (tester) async {
      await tester.pumpWidget(_card(_sleepGroup()));
      await tester.pumpAndSettle();

      expect(find.text('8:00 h'), findsOneWidget);
      expect(find.text('1:30 h'), findsOneWidget);
    });

    testWidgets('the roll-up row gets no colour dot', (tester) async {
      await tester.pumpWidget(_card(_sleepGroup()));
      await tester.pumpAndSettle();

      // Total sleep is no segment of the stack, so no colour identifies it
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect(tiles.first.leading, isNull);
      expect(tiles.skip(1).every((t) => t.leading != null), isTrue);
    });
  });

  group('CategoriesCard daily aggregates', () {
    /// A heart rate category as the importer stores it: one entry per day
    /// holding the day's average, with the range it summarises in extra_data.
    _Seed heartRate({bool withRange = true}) => (
      category: MeasurementCategory(
        id: 'hr',
        name: 'Heart rate',
        unit: 'bpm',
        metricType: MetricType.heartRate,
      ),
      entries: {
        'hr': [
          for (var day = 1; day <= 3; day++)
            MeasurementEntry(
              id: 'e$day',
              categoryId: 'hr',
              date: DateTime(2026, 1, day),
              value: 60 + day,
              notes: '',
              source: 'apple',
              extraData: withRange ? {'min': 50 + day, 'max': 90 + day} : const {},
            ),
        ],
      },
    );

    testWidgets('draws the summarised range as a band around the line', (tester) async {
      await tester.pumpWidget(_card(heartRate()));
      await tester.pumpAndSettle();

      final data = tester.widget<LineChart>(find.byType(LineChart)).data;
      expect(data.betweenBarsData, hasLength(1));
      // the bounds come from extra_data, the line they wrap from the values
      final bounds = data.betweenBarsData.single;
      expect(data.lineBarsData[bounds.fromIndex].spots.map((s) => s.y), [51, 52, 53]);
      expect(data.lineBarsData[bounds.toIndex].spots.map((s) => s.y), [91, 92, 93]);
      expect(data.lineBarsData[bounds.toIndex + 1].spots.map((s) => s.y), [61, 62, 63]);
    });

    testWidgets('plain entries get no band', (tester) async {
      await tester.pumpWidget(_card(heartRate(withRange: false)));
      await tester.pumpAndSettle();

      expect(tester.widget<LineChart>(find.byType(LineChart)).data.betweenBarsData, isEmpty);
    });
  });
}
