import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:wger/helpers/colors.dart';
import 'package:wger/models/nutrition/nutritional_goals.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/screens/nutritional_diary_screen.dart';

class NutritionalDiaryTable extends StatelessWidget {
  const NutritionalDiaryTable({
    super.key,
    required NutritionalPlan nutritionalPlan,
  }) : plan = nutritionalPlan;

  final NutritionalPlan plan;

  @override
  Widget build(BuildContext context) {
    final goals = plan.nutritionalGoals;

    return Table(
      columnWidths: const {
        0: FractionColumnWidth(0.14), // Date
        1: FractionColumnWidth(0.19), // E (kcal)
        2: FractionColumnWidth(0.25), // Difference
        3: FractionColumnWidth(0.14), // P (g)
        4: FractionColumnWidth(0.14), // C (g)
        5: FractionColumnWidth(0.14), // F (g)
      },
      children: [
        nutrionalDiaryHeader(context, goals),
        ...plan.logEntriesValues.entries
            .map((entry) => nutritionDiaryEntry(context, goals, entry.key, entry.value))
            .toList()
            .reversed,
      ],
    );
  }

  TableRow nutrionalDiaryHeader(BuildContext context, NutritionalGoals goals) {
    return TableRow(
      children: [
        Text(style: Theme.of(context).textTheme.titleMedium, 'Date'),
        Text(
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.end,
          '${AppLocalizations.of(context).energyShort} (${AppLocalizations.of(context).kcal})',
        ),
        if (goals.energy != null)
          Text(
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.end,
            AppLocalizations.of(context).difference,
          ),
        Text(
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.end,
          '${AppLocalizations.of(context).proteinShort} (${AppLocalizations.of(context).g})',
        ),
        Text(
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.end,
          '${AppLocalizations.of(context).carbohydratesShort} (${AppLocalizations.of(context).g})',
        ),
        Text(
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.end,
          '${AppLocalizations.of(context).fatShort} (${AppLocalizations.of(context).g})',
        ),
      ],
    );
  }

  TableRow nutritionDiaryEntry(
    final BuildContext context,
    NutritionalGoals goals,
    DateTime date,
    final NutritionalValues values,
  ) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      children: [
        Text(
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: LIST_OF_COLORS3.first),
          DateFormat.Md(Localizations.localeOf(context).languageCode).format(date),
        ),
        Text(
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.end,
          values.energy.toStringAsFixed(0),
        ),
        if (goals.energy != null)
          Text(
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.end,
            (values.energy - goals.energy!).toStringAsFixed(0),
          ),
        Text(
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.end,
          values.protein.toStringAsFixed(0),
        ),
        Text(
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.end,
          values.carbohydrates.toStringAsFixed(0),
        ),
        Text(
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.end,
          values.fat.toStringAsFixed(0),
        ),
      ].map((element) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            NutritionalDiaryScreen.routeName,
            arguments: NutritionalDiaryArguments(plan, date),
          ),
          child: element,
        );
      }).toList(),
    );
  }
}
