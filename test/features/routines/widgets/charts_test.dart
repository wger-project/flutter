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
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/routines/models/log.dart';
import 'package:wger/features/routines/widgets/charts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

void main() {
  Widget createChartScreen(Map<num, List<Log>> data) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            height: 300,
            width: 300,
            child: LogChartWidgetFl(data),
          ),
        ),
      ),
    );
  }

  Log makeLog(num repetitions, num weight, DateTime date) => Log(
    exerciseId: 1,
    repetitions: repetitions,
    weight: weight,
    date: date,
  );

  testWidgets('renders a chart with logs', (WidgetTester tester) async {
    await tester.pumpWidget(
      createChartScreen({
        10: [
          makeLog(10, 100, DateTime(2026, 7, 1)),
          makeLog(10, 110, DateTime(2026, 7, 8)),
        ],
        8: [makeLog(8, 120, DateTime(2026, 7, 15))],
      }),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('does not crash without any logs', (WidgetTester tester) async {
    await tester.pumpWidget(createChartScreen({}));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('a group without logs is nothing to plot either', (WidgetTester tester) async {
    await tester.pumpWidget(createChartScreen({10: []}));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(LineChart), findsNothing);
  });

  /// The interval the date axis is labelled at
  double? intervalOf(WidgetTester tester) => tester
      .widget<LineChart>(find.byType(LineChart))
      .data
      .titlesData
      .bottomTitles
      .sideTitles
      .interval;

  testWidgets('spaces the date labels over everything that is plotted', (
    WidgetTester tester,
  ) async {
    // The groups are keyed by repetitions, so the first and the last of them
    // say nothing about the range: here they sit on one day while the logs
    // span a year. An interval taken from those two would be minutes wide on
    // a year-long axis, and fl_chart builds one label per step
    final start = DateTime(2026, 1, 1);
    final end = DateTime(2026, 12, 31);
    await tester.pumpWidget(
      createChartScreen({
        // Insertion order decides what `keys.first` and `keys.last` are, and
        // both of these sit on the same July day
        10: [makeLog(10, 100, DateTime(2026, 7, 1))],
        // while the series that spans the axis is neither of them
        5: [makeLog(5, 140, start), makeLog(5, 150, end)],
        8: [makeLog(8, 120, DateTime(2026, 7, 1))],
      }),
    );
    await tester.pumpAndSettle();

    // Taken from the two July logs the span reads as zero, which used to fall
    // back to a hundred seconds: fl_chart would then label a year-long axis
    // every hundred seconds, some three hundred thousand times over
    expect(intervalOf(tester), end.difference(start).inMilliseconds / 3);
  });
}
