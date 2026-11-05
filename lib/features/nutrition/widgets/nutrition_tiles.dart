import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/features/nutrition/models/ingredient.dart';
import 'package:wger/features/nutrition/models/log.dart';
import 'package:wger/features/nutrition/models/nutritional_plan.dart';
import 'package:wger/features/nutrition/models/nutritional_values.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/features/nutrition/widgets/forms/diary_entry_edit.dart';
import 'package:wger/features/nutrition/widgets/helpers.dart';
import 'package:wger/features/nutrition/widgets/nutrition_tile.dart';
import 'package:wger/features/nutrition/widgets/widgets.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// a NutritionTitle showing an ingredient, with its
/// avatar, nutritional values and button to popup its details
class MealItemValuesTile extends ConsumerWidget {
  final Ingredient ingredient;
  final NutritionalValues nutritionalValues;

  const MealItemValuesTile({
    super.key,
    required this.ingredient,
    required this.nutritionalValues,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NutritionTile(
      leading: IngredientAvatar(ingredient: ingredient),
      title: Text(getShortNutritionValues(nutritionalValues, context)),
      trailing: IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: () {
          showIngredientDetails(context, ref, ingredient);
        },
      ),
    );
  }
}

/// a NutritionTitle showing the header for the diary
class DiaryheaderTile extends StatelessWidget {
  final Widget? leading;

  const DiaryheaderTile({this.leading});

  @override
  Widget build(BuildContext context) {
    return NutritionTile(title: getNutritionRow(context, muted(getNutritionColumnNames(context))));
  }
}

/// a NutritionTitle showing diary entries
class DiaryEntryTile extends ConsumerWidget {
  const DiaryEntryTile({
    super.key,
    required this.diaryEntry,
    this.nutritionalPlan,
  });

  final LogItem diaryEntry;
  final NutritionalPlan? nutritionalPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NutritionTile(
      leading: Text(
        DateFormat.Hm(Localizations.localeOf(context).languageCode).format(diaryEntry.datetime),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      title: Text(
        // Ingredient is null briefly between local insert and PowerSync
        // pulling the row down, show an ellipsis placeholder.
        diaryEntry.weightUnitObj != null
            ? '${diaryEntry.amount.toStringAsFixed(0)} × ${diaryEntry.weightUnitObj!.name} ${diaryEntry.ingredient?.name ?? '…'}'
            : '${AppLocalizations.of(context).gValue(diaryEntry.amount.toStringAsFixed(0))} ${diaryEntry.ingredient?.name ?? '…'}',
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: getNutritionRow(
        context,
        muted(getNutritionalValues(diaryEntry.nutritionalValues, context)),
      ),
      trailingWidth: nutritionalPlan == null ? 20 : 96,
      trailing: (nutritionalPlan == null)
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: AppLocalizations.of(context).edit,
                  onPressed: diaryEntry.id == null
                      ? null
                      : () {
                          showDialog<void>(
                            context: context,
                            builder: (_) => DiaryEntryEditDialog(entry: diaryEntry),
                          );
                        },
                  icon: const Icon(Icons.edit_outlined),
                  iconSize: ICON_SIZE_SMALL,
                ),
                IconButton(
                  tooltip: AppLocalizations.of(context).delete,
                  onPressed: () {
                    ref.read(nutritionProvider.notifier).deleteLog(diaryEntry.id!);
                  },
                  icon: const Icon(Icons.delete_outline),
                  iconSize: ICON_SIZE_SMALL,
                ),
              ],
            ),
    );
  }
}
