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

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/features/measurements/charts/data.dart';
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
