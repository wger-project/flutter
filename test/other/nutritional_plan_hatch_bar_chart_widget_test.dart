import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import 'package:wger/widgets/nutrition/helpers.dart';

import '../../test_data/nutritional_plans.dart';

void main() {

  Widget getWidget({locale = 'en'}) {
    return MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: NutritionalPlanHatchBarChartWidget(getNutritionalPlan()),
    );
  }

  testWidgets('selection can be set programmatically',
          (WidgetTester tester) async {

        await tester.pumpWidget(getWidget());
        await tester.tap(find.byType(charts.BarChart));
        await tester.pumpAndSettle();

        //expect(find.text('Category'), findsOneWidget);

        /*final onTapSelection =
        charts.UserManagedSelectionModel<String>.fromConfig(
            selectedDataConfig: [
              charts.SeriesDatumConfig<String>('Sales', '2016')
            ]);

        charts.SelectionModel<String>? currentSelectionModel;

        void selectionChangedListener(charts.SelectionModel<String> model) {
          currentSelectionModel = model;
        }*/

        //final testChart = TestChart(selectionChangedListener, onTapSelection);

      });
}