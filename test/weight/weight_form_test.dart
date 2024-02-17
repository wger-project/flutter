/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/widgets/weight/forms.dart';

import '../../test_data/body_weight.dart';

void main() {
  Widget createWeightForm({locale = 'en', weightEntry = WeightEntry}) {
    return MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: WeightForm(weightEntry),
      ),
    );
  }

  testWidgets('The form is prefilled with the data from an entry', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightForm(weightEntry: testWeightEntry1));
    await tester.pumpAndSettle();

    expect(find.text('2021-01-01'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
  });

  testWidgets('It is possible to quick-change the weight', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightForm(weightEntry: testWeightEntry1));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('quickMinus')));
    expect(find.text('79'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quickMinusSmall')));
    expect(find.text('78.75'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quickPlus')));
    expect(find.text('79.75'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quickPlusSmall')));
    expect(find.text('80.0'), findsOneWidget);
  });

  testWidgets("Entering garbage doesn't break the quick-change", (WidgetTester tester) async {
    await tester.pumpWidget(createWeightForm(weightEntry: testWeightEntry1));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('weightInput')), 'shiba inu');

    await tester.tap(find.byKey(const Key('quickMinus')));
    expect(find.text('shiba inu'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quickMinusSmall')));
    expect(find.text('shiba inu'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quickPlus')));
    expect(find.text('shiba inu'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quickPlusSmall')));
    expect(find.text('shiba inu'), findsOneWidget);
  });

  testWidgets('Widget works if there is no last entry', (WidgetTester tester) async {
    await tester.pumpWidget(createWeightForm(weightEntry: null));
    await tester.pumpAndSettle();
  });
}
