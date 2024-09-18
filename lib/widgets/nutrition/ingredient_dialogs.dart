import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/models/nutrition/nutritional_goals.dart';
import 'package:wger/widgets/nutrition/macro_nutrients_table.dart';

Widget ingredientImage(String url, BuildContext context) {
  var radius = 100.0;
  final height = MediaQuery.sizeOf(context).height;
  final width = MediaQuery.sizeOf(context).width;
  final smallest = height < width ? height : width;
  if (smallest < 400) {
    radius = smallest / 4;
  }
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: CircleAvatar(backgroundImage: NetworkImage(url), radius: radius),
  );
}

class IngredientDetails extends StatelessWidget {
  final AsyncSnapshot<Ingredient> snapshot;
  final void Function()? onSelect;
  const IngredientDetails(this.snapshot, {super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    Ingredient? ingredient;
    NutritionalGoals? goals;
    String? source;

    if (snapshot.hasData) {
      ingredient = snapshot.data;
      goals = ingredient!.nutritionalValues.toGoals();
      source = ingredient.sourceName ?? 'unknown';
    }

    return AlertDialog(
      title: (snapshot.hasData) ? Text(ingredient!.name) : null,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (snapshot.hasError)
                Text(
                  'Ingredient lookup error: ${snapshot.error ?? 'unknown error'}',
                  style: const TextStyle(color: Colors.red),
                ),
              if (ingredient?.image?.image != null)
                ingredientImage(ingredient!.image!.image, context),
              if (!snapshot.hasData && !snapshot.hasError) const CircularProgressIndicator(),
              if (snapshot.hasData)
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 400),
                  child: MacronutrientsTable(
                    nutritionalGoals: goals!,
                    plannedValuesPercentage: goals.energyPercentage(),
                    showGperKg: false,
                  ),
                ),
              if (snapshot.hasData && ingredient!.licenseObjectURl == null)
                Text('Source: ${source!}'),
              if (snapshot.hasData && ingredient!.licenseObjectURl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: InkWell(
                    child: Text('Source: ${source!}'),
                    onTap: () => launchURL(ingredient!.licenseObjectURl!, context),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (snapshot.hasData && onSelect != null)
          TextButton(
            key: const Key('ingredient-details-continue-button'),
            child: Text(MaterialLocalizations.of(context).continueButtonLabel),
            onPressed: () {
              onSelect!();
              Navigator.of(context).pop();
            },
          ),
        TextButton(
          key: const Key('ingredient-details-close-button'),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class IngredientScanResultDialog extends StatelessWidget {
  final AsyncSnapshot<Ingredient?> snapshot;
  final String barcode;
  final Function(int id, String name, num? amount) onSelectIngredient;

  const IngredientScanResultDialog(
    this.snapshot,
    this.barcode,
    this.onSelectIngredient, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Ingredient? ingredient;
    NutritionalGoals? goals;
    String? title;
    String? source;

    if (snapshot.connectionState == ConnectionState.done) {
      ingredient = snapshot.data;
      title = ingredient != null
          ? AppLocalizations.of(context).productFound
          : AppLocalizations.of(context).productNotFound;
      if (ingredient != null) {
        goals = ingredient.nutritionalValues.toGoals();
        source = ingredient.sourceName ?? 'unknown';
      }
    }
    return AlertDialog(
      key: const Key('ingredient-scan-result-dialog'),
      title: title != null ? Text(title) : null,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (snapshot.hasError)
                Text(
                  'Ingredient lookup error: ${snapshot.error ?? 'unknown error'}',
                  style: const TextStyle(color: Colors.red),
                ),
              if (snapshot.connectionState == ConnectionState.done && ingredient == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    AppLocalizations.of(context).productNotFoundDescription(barcode),
                  ),
                ),
              if (ingredient != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child:
                      Text(AppLocalizations.of(context).productFoundDescription(ingredient.name)),
                ),
              if (ingredient?.image?.image != null)
                ingredientImage(ingredient!.image!.image, context),
              if (snapshot.connectionState != ConnectionState.done && !snapshot.hasError)
                const CircularProgressIndicator(),
              if (goals != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 400),
                  child: MacronutrientsTable(
                    nutritionalGoals: goals,
                    plannedValuesPercentage: goals.energyPercentage(),
                    showGperKg: false,
                  ),
                ),
              if (ingredient != null && ingredient.licenseObjectURl == null)
                Text('Source: ${source!}'),
              if (ingredient?.licenseObjectURl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: InkWell(
                    child: Text('Source: ${source!}'),
                    onTap: () => launchURL(ingredient!.licenseObjectURl!, context),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        if (ingredient != null) // if barcode matched
          TextButton(
            key: const Key('ingredient-scan-result-dialog-confirm-button'),
            child: Text(MaterialLocalizations.of(context).continueButtonLabel),
            onPressed: () {
              onSelectIngredient(ingredient!.id, ingredient.name, null);
              Navigator.of(context).pop();
            },
          ),
        // if didn't match, or we're still waiting
        TextButton(
          key: const Key('ingredient-scan-result-dialog-close-button'),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
