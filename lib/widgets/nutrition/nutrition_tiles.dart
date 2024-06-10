import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/models/nutrition/nutritional_values.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/nutrition/helpers.dart';
import 'package:wger/widgets/nutrition/nutrition_tile.dart';
import 'package:wger/widgets/nutrition/widgets.dart';

/// a NutritionTitle showing an ingredient, with its
/// avatar and nutritional values
class MealItemValuesTile extends StatelessWidget {
  final Ingredient ingredient;
  final NutritionalValues nutritionalValues;

  const MealItemValuesTile({
    super.key,
    required this.ingredient,
    required this.nutritionalValues,
  });

  @override
  Widget build(BuildContext context) {
    return NutritionTile(
      leading: IngredientAvatar(ingredient: ingredient),
      title: Text(getShortNutritionValues(nutritionalValues, context)), // TODO align
    );
  }
}

/// a NutritionTitle showing the header for the diary
class DiaryheaderTile extends StatelessWidget {
  final Widget? leading;

  const DiaryheaderTile({this.leading});

  @override
  Widget build(BuildContext context) {
    return NutritionTile(
      title: getNutritionRow(
          context,
          [
            AppLocalizations.of(context).energy,
            AppLocalizations.of(context).protein,
            AppLocalizations.of(context).carbohydrates,
            AppLocalizations.of(context).fat,
          ]
              .map((e) => MutedText(
                    e,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ))
              .toList()),
    );
  }
}

/// a NutritionTitle showing diary entries
class DiaryEntryTile extends StatelessWidget {
  const DiaryEntryTile({
    super.key,
    required this.diaryEntry,
    this.nutritionalPlan,
  });

  final Log diaryEntry;
  final NutritionalPlan? nutritionalPlan;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          DateFormat.Hm(Localizations.localeOf(context).languageCode).format(diaryEntry.datetime),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppLocalizations.of(context).gValue(diaryEntry.amount.toStringAsFixed(0))} ${diaryEntry.ingredient.name}',
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ...getMutedNutritionalValues(diaryEntry.nutritionalValues, context),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        if (nutritionalPlan != null)
          IconButton(
            tooltip: AppLocalizations.of(context).delete,
            onPressed: () {
              Provider.of<NutritionPlansProvider>(context, listen: false)
                  .deleteLog(diaryEntry.id!, nutritionalPlan!.id!);
            },
            icon: const Icon(Icons.delete_outline),
            iconSize: ICON_SIZE_SMALL,
          ),
      ],
    );
  }
}
