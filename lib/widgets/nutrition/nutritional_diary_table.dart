import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:wger/helpers/colors.dart';
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
    return Table(
      children: [
        nutrionalDiaryHeader(context),
        ...plan.logEntriesValues.entries
            .map((entry) => nutritionDiaryEntry(context, entry.key, entry.value))
            .toList()
            .reversed,
      ],
    );
  }

  TableRow nutrionalDiaryHeader(BuildContext context) {
    return TableRow(
      children: [
        const Text('Date'),
        Text('${AppLocalizations.of(context).energyShort} (${AppLocalizations.of(context).kcal})'),
        if (plan.goalEnergy != null) Text(AppLocalizations.of(context).difference),
        Text('${AppLocalizations.of(context).protein} (${AppLocalizations.of(context).g})'),
        Text(
            '${AppLocalizations.of(context).carbohydratesShort} (${AppLocalizations.of(context).g})'),
        Text('${AppLocalizations.of(context).fatShort} (${AppLocalizations.of(context).g})'),
      ],
    );
  }

  TableRow nutritionDiaryEntry(
      final BuildContext context, final DateTime date, final NutritionalValues values) {
    return TableRow(
      children: [
        GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(
                  NutritionalDiaryScreen.routeName,
                  arguments: NutritionalDiaryArguments(plan, date),
                ),
            child: Text(
              style:
                  Theme.of(context).textTheme.titleMedium?.copyWith(color: LIST_OF_COLORS3.first),
              DateFormat.Md(Localizations.localeOf(context).languageCode).format(date),
            )),
        Text(values.energy.toStringAsFixed(0)),
        if (plan.goalEnergy != null) Text((values.energy - plan.goalEnergy!).toStringAsFixed(0)),
        Text(values.protein.toStringAsFixed(0)),
        Text(values.carbohydrates.toStringAsFixed(0)),
        Text(values.fat.toStringAsFixed(0)),
      ],
    );
  }
}
