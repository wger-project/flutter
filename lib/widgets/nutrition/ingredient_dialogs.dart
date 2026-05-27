/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/widgets/core/error.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/core/wger_image.dart';
import 'package:wger/widgets/nutrition/macro_nutrients_table.dart';
import 'package:wger/widgets/nutrition/nutri_score_badge.dart';

class IngredientImageHeader extends StatelessWidget {
  const IngredientImageHeader({super.key, required this.mediaPath});

  /// Path relative to MEDIA_ROOT (as stored on `IngredientImage.image`),
  /// or `null` to render the placeholder `WgerImage` falls back to.
  final String? mediaPath;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final smallest = size.shortestSide;
    final radius = smallest > 400 ? smallest / 2.5 : 100.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: radius,
          width: size.width,
          child: Stack(
            children: [
              WgerImage(
                mediaPath: mediaPath,
                height: radius,
                width: size.width,
                fit: BoxFit.cover,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                child: SizedBox(height: radius, width: size.width),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: WgerImage(
                      mediaPath: mediaPath,
                      height: radius,
                      width: size.width,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IngredientDetailsDialog extends StatelessWidget {
  final Ingredient ingredient;
  final void Function()? onSelect;

  const IngredientDetailsDialog(this.ingredient, {super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final goals = ingredient.nutritionalValues.toGoals();
    final source = ingredient.sourceName ?? 'unknown';

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(ingredient.name),
          if (ingredient.brand case final brand? when brand.isNotEmpty)
            Text(
              brand,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 400),
            child: IngredientDetails(ingredient, onSelect: onSelect),
          ),
        ),
      ),
      actions: [
        if (onSelect != null)
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

class IngredientDetails extends StatelessWidget {
  final Ingredient ingredient;
  final void Function()? onSelect;

  const IngredientDetails(this.ingredient, {super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final goals = ingredient.nutritionalValues.toGoals();
    final source = ingredient.sourceName ?? 'unknown';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (ingredient.image?.image != null)
          IngredientImageHeader(mediaPath: ingredient.image!.image),

        Text(
          AppLocalizations.of(context).macronutrients,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        MacronutrientsTable(
          nutritionalGoals: goals,
          plannedValuesPercentage: goals.energyPercentage(),
          showGperKg: false,
        ),

        DietaryInfoSection(ingredient: ingredient),

        if (ingredient.licenseObjectURl == null)
          Center(child: Text('Source: $source'))
        else
          Center(
            child: InkWell(
              child: Text(
                'Source: $source',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
              onTap: () => launchURL(ingredient.licenseObjectURl!, context),
            ),
          ),
      ],
    );
  }
}

class IngredientScanResultDialog extends StatelessWidget {
  final AsyncSnapshot<Ingredient?> snapshot;
  final String barcode;
  final Function(Ingredient ingredient, num? amount) onSelectIngredient;

  const IngredientScanResultDialog(
    this.snapshot,
    this.barcode,
    this.onSelectIngredient, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    // Scan still running: show a spinner.
    if (snapshot.connectionState != ConnectionState.done) {
      return AlertDialog(
        key: const Key('ingredient-scan-result-dialog'),
        content: const BoxedProgressIndicator(),
        actions: [_closeButton(context)],
      );
    }

    // Scan threw: surface the error with the shared indicator.
    if (snapshot.hasError) {
      return AlertDialog(
        key: const Key('ingredient-scan-result-dialog'),
        content: StreamErrorIndicator(snapshot.error!, stacktrace: snapshot.stackTrace),
        actions: [_closeButton(context)],
      );
    }

    final ingredient = snapshot.data;

    // No product matched the barcode, offer the user to add it to OFF.
    if (ingredient == null) {
      return AlertDialog(
        key: const Key('ingredient-scan-result-dialog'),
        title: Text(i18n.productNotFound),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(i18n.productNotFoundDescription(barcode)),
              const SizedBox(height: 8),
              Text(i18n.productNotFoundOpenFoodFacts),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            key: const Key('ingredient-scan-result-dialog-open-food-facts-button'),
            icon: const Icon(Icons.add_circle_outline),
            label: Text(i18n.addToOpenFoodFacts),
            onPressed: () {
              launchURL('https://world.openfoodfacts.org/cgi/product.pl', context);
              Navigator.of(context).pop();
            },
          ),
          _closeButton(context),
        ],
      );
    }

    // Product found, render details + confirm button.
    final goals = ingredient.nutritionalValues.toGoals();
    final source = ingredient.sourceName ?? 'unknown';
    return AlertDialog(
      key: const Key('ingredient-scan-result-dialog'),
      title: Text(i18n.productFound),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(i18n.productFoundDescription(ingredient.name)),
              ),
              if (ingredient.image?.image != null)
                IngredientImageHeader(mediaPath: ingredient.image!.image),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 400),
                child: MacronutrientsTable(
                  nutritionalGoals: goals,
                  plannedValuesPercentage: goals.energyPercentage(),
                  showGperKg: false,
                ),
              ),
              if (ingredient.licenseObjectURl == null)
                Text('Source: $source')
              else
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: InkWell(
                    child: Text('Source: $source'),
                    onTap: () => launchURL(ingredient.licenseObjectURl!, context),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('ingredient-scan-result-dialog-confirm-button'),
          child: Text(MaterialLocalizations.of(context).continueButtonLabel),
          onPressed: () {
            onSelectIngredient(ingredient, null);
            Navigator.of(context).pop();
          },
        ),
        _closeButton(context),
      ],
    );
  }

  Widget _closeButton(BuildContext context) => TextButton(
    key: const Key('ingredient-scan-result-dialog-close-button'),
    child: Text(MaterialLocalizations.of(context).closeButtonLabel),
    onPressed: () => Navigator.of(context).pop(),
  );
}

class DietaryInfoSection extends StatelessWidget {
  final Ingredient ingredient;

  const DietaryInfoSection({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).dietaryInformation,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(i18n.isVegan),
            if (ingredient.isVegan == null)
              const Text('N/A')
            else if (ingredient.isVegan!)
              Icon(Icons.eco, color: Colors.green[700])
            else
              Icon(Icons.block, color: Colors.red[400]),
          ],
        ),
        const Divider(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(i18n.isVegetarian),
            if (ingredient.isVegetarian == null)
              const Text('N/A')
            else if (ingredient.isVegetarian!)
              Icon(Icons.eco, color: Colors.green[700])
            else
              Icon(Icons.block, color: Colors.red[400]),
          ],
        ),
        const Divider(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Nutri-Score'),
            if (ingredient.nutriscore != null)
              NutriScoreBadge(score: ingredient.nutriscore!)
            else
              const Text('N/A'),
          ],
        ),
      ],
    );
  }
}
