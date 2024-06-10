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
    final loc = AppLocalizations.of(context);

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
                loc.macronutrients,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              loc.total,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              loc.percentEnergy,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              loc.gPerBodyKg,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(loc.energy),
            ),
            Text(
              nutritionalGoals.energy != null
                  ? loc.kcalValue(nutritionalGoals.energy!.toStringAsFixed(0))
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
              child: Text(loc.protein),
            ),
            Text(nutritionalGoals.protein != null
                ? loc.gValue(nutritionalGoals.protein!.toStringAsFixed(0))
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
              child: Text(loc.carbohydrates),
            ),
            Text(nutritionalGoals.carbohydrates != null
                ? loc.gValue(nutritionalGoals.carbohydrates!.toStringAsFixed(0))
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
              child: Text(loc.sugars),
            ),
            const Text(''),
            const Text(''),
            Text(nutritionalGoals.carbohydratesSugar != null
                ? loc.gValue(nutritionalGoals.carbohydratesSugar!.toStringAsFixed(0))
                : ''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(loc.fat),
            ),
            Text(nutritionalGoals.fat != null
                ? loc.gValue(nutritionalGoals.fat!.toStringAsFixed(0))
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
              child: Text(loc.saturatedFat),
            ),
            const Text(''),
            const Text(''),
            Text(nutritionalGoals.fatSaturated != null
                ? loc.gValue(nutritionalGoals.fatSaturated!.toStringAsFixed(0))
                : ''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(loc.fiber),
            ),
            const Text(''),
            const Text(''),
            Text(nutritionalGoals.fiber != null
                ? loc.gValue(nutritionalGoals.fiber!.toStringAsFixed(0))
                : ''),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: tablePadding),
              child: Text(loc.sodium),
            ),
            const Text(''),
            const Text(''),
            Text(nutritionalGoals.sodium != null
                ? loc.gValue(nutritionalGoals.sodium!.toStringAsFixed(0))
                : ''),
          ],
        ),
      ],
    );
  }
}
