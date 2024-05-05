import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wger/models/nutrition/nutritional_goals.dart';

class MacronutrientsTable extends StatelessWidget {
  const MacronutrientsTable({
    super.key,
    required this.nutritionalGoals,
    required this.plannedValuesPercentage,
    required this.nutritionalGoalsGperKg,
  });

  static const double tablePadding = 7;
  final NutritionalGoals nutritionalGoals;
  final NutritionalGoals plannedValuesPercentage;
  final NutritionalGoals? nutritionalGoalsGperKg;

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside: BorderSide(
          width: 1,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      columnWidths: const {0: FractionColumnWidth(0.4)},
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(
                AppLocalizations.of(context).macronutrients,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              AppLocalizations.of(context).total,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              AppLocalizations.of(context).percentEnergy,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              AppLocalizations.of(context).gPerBodyKg,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).energy),
            ),
            Text(
              nutritionalGoals.energy != null
                  ? nutritionalGoals.energy!.toStringAsFixed(0) + AppLocalizations.of(context).kcal
                  : '',
            ),
            const Text(''),
            const Text(''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).protein),
            ),
            Text(nutritionalGoals.protein != null
                ? nutritionalGoals.protein!.toStringAsFixed(0) + AppLocalizations.of(context).g
                : ''),
            Text(plannedValuesPercentage.protein != null
                ? plannedValuesPercentage.protein!.toStringAsFixed(1)
                : ''),
            Text(nutritionalGoalsGperKg != null && nutritionalGoalsGperKg!.protein != null
                ? nutritionalGoalsGperKg!.protein!.toStringAsFixed(1)
                : ''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).carbohydrates),
            ),
            Text(nutritionalGoals.carbohydrates != null
                ? nutritionalGoals.carbohydrates!.toStringAsFixed(0) +
                    AppLocalizations.of(context).g
                : ''),
            Text(plannedValuesPercentage.carbohydrates != null
                ? plannedValuesPercentage.carbohydrates!.toStringAsFixed(1)
                : ''),
            Text(nutritionalGoalsGperKg != null && nutritionalGoalsGperKg!.carbohydrates != null
                ? nutritionalGoalsGperKg!.carbohydrates!.toStringAsFixed(1)
                : ''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding, horizontal: 12),
              child: Text(AppLocalizations.of(context).sugars),
            ),
            const Text(''),
            const Text(''),
            Text(nutritionalGoals.carbohydratesSugar != null
                ? nutritionalGoals.carbohydratesSugar!.toStringAsFixed(0) +
                    AppLocalizations.of(context).g
                : ''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).fat),
            ),
            Text(nutritionalGoals.fat != null
                ? nutritionalGoals.fat!.toStringAsFixed(0) + AppLocalizations.of(context).g
                : ''),
            Text(plannedValuesPercentage.fat != null
                ? plannedValuesPercentage.fat!.toStringAsFixed(1)
                : ''),
            Text(nutritionalGoalsGperKg != null && nutritionalGoalsGperKg!.fat != null
                ? nutritionalGoalsGperKg!.fat!.toStringAsFixed(1)
                : ''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding, horizontal: 12),
              child: Text(AppLocalizations.of(context).saturatedFat),
            ),
            const Text(''),
            const Text(''),
            Text(nutritionalGoals.fatSaturated != null
                ? nutritionalGoals.fatSaturated!.toStringAsFixed(0) + AppLocalizations.of(context).g
                : ''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).fibres),
            ),
            const Text(''),
            const Text(''),
            Text(nutritionalGoals.fibres != null
                ? nutritionalGoals.fibres!.toStringAsFixed(0) + AppLocalizations.of(context).g
                : ''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(AppLocalizations.of(context).sodium),
            ),
            const Text(''),
            const Text(''),
            Text(nutritionalGoals.sodium != null
                ? nutritionalGoals.sodium!.toStringAsFixed(0) + AppLocalizations.of(context).g
                : ''),
          ],
        ),
      ],
    );
  }
}
