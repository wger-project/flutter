import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/meal.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/widgets/nutrition/charts.dart';
import '../../test_data/nutritional_plans.dart';

void main() {

  final plan1 = NutritionalPlan.empty();
  final plan2 = getNutritionalPlan();
  final plan3 = getNutritionalPlan();
  var meal1 = Meal();

  Widget getWidget(NutritionalPlan nutritionalPlan, {locale = 'en'}) {
    return MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: NutritionalPlanHatchBarChartWidget(nutritionalPlan),
    );
  }

  setUp(() {
    meal1 = plan3.meals.first;

    final now = DateTime.now();

    for(var i = 0; i <= 7; i++) {
      var key = DateTime(now.year, now.month, now.day -(1*i));
      plan3.logs.add(Log.fromMealItem(meal1.mealItems.first, 1, 1, key));
    }
  });


  testWidgets('Test the widget with and without '
      'nutritional values',
          (WidgetTester tester) async {

        await tester.pumpWidget(getWidget(plan2));
        expect(find.byType(charts.BarChart), findsOneWidget);
        await tester.pumpWidget(getWidget(plan1));
        expect(find.byType(Container), findsOneWidget);

        await tester.pumpWidget(getWidget(plan3));
        expect(find.byType(charts.BarChart), findsOneWidget);

        await tester.pumpAndSettle();

      });
}