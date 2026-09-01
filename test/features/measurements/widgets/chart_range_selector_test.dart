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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/features/measurements/charts/range.dart';
import 'package:wger/features/measurements/widgets/chart_range_selector.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

void main() {
  late ChartRange picked;

  Future<void> pumpSelector(WidgetTester tester, ChartRange selected) async {
    picked = selected;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ChartRangeSelector(
            value: selected,
            onChanged: (range) => picked = range,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('every range is offered', (tester) async {
    await pumpSelector(tester, ChartRange.last3Months);

    final context = tester.element(find.byType(ChartRangeSelector));
    final i18n = AppLocalizations.of(context);
    for (final range in ChartRange.values) {
      expect(find.text(range.label(i18n)), findsOneWidget, reason: range.name);
    }
  });

  testWidgets('picking a range reports that range', (tester) async {
    for (final range in ChartRange.values) {
      // Start on another one, so a selector that always reports its own value
      // cannot pass
      await pumpSelector(
        tester,
        range == ChartRange.all ? ChartRange.lastWeek : ChartRange.all,
      );
      final context = tester.element(find.byType(ChartRangeSelector));

      await tester.tap(find.text(range.label(AppLocalizations.of(context))));
      await tester.pumpAndSettle();

      expect(picked, range, reason: range.name);
    }
  });
}
