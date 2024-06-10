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

    Widget columnHeader(bool left, String title) => Padding(
          padding: const EdgeInsets.symmetric(vertical: tablePadding),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: left ? TextAlign.left : TextAlign.right,
          ),
        );

    TableRow macroRow(int indent, bool g, String title, double? Function(NutritionalGoals ng) get) {
      final goal = get(nutritionalGoals);
      final pct = get(plannedValuesPercentage);
      final perkg = nutritionalGoalsGperKg == null ? null : get(nutritionalGoalsGperKg!);
      final valFn = g ? loc.gValue : loc.kcalValue;

      return TableRow(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: tablePadding, horizontal: indent * 12),
            child: Text(title),
          ),
          Text(goal != null ? valFn(goal.toStringAsFixed(0)) : '', textAlign: TextAlign.right),
          Text(pct != null ? pct.toStringAsFixed(1) : '', textAlign: TextAlign.right),
          Text(perkg != null ? perkg.toStringAsFixed(1) : '', textAlign: TextAlign.right),
        ],
      );
    }

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
            columnHeader(true, loc.macronutrients),
            columnHeader(false, loc.total),
            columnHeader(false, loc.percentEnergy),
            columnHeader(false, loc.gPerBodyKg),
          ],
        ),
        macroRow(0, false, loc.energy, (NutritionalGoals ng) => ng.energy),
        macroRow(0, true, loc.protein, (NutritionalGoals ng) => ng.protein),
        macroRow(0, true, loc.carbohydrates, (NutritionalGoals ng) => ng.carbohydrates),
        macroRow(1, true, loc.sugars, (NutritionalGoals ng) => ng.carbohydratesSugar),
        macroRow(0, true, loc.fat, (NutritionalGoals ng) => ng.fat),
        macroRow(1, true, loc.saturatedFat, (NutritionalGoals ng) => ng.fatSaturated),
        macroRow(0, true, loc.fiber, (NutritionalGoals ng) => ng.fiber),
        macroRow(0, true, loc.sodium, (NutritionalGoals ng) => ng.sodium),
      ],
    );
  }
}
