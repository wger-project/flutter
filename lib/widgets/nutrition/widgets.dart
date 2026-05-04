/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/helpers/platform.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/core/search_options.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/providers/nutrition_ingredient_filters_riverpod.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/nutrition/helpers.dart';
import 'package:wger/widgets/nutrition/ingredient_dialogs.dart';
import 'package:wger/widgets/nutrition/ingredient_filter_dialog.dart';
import 'package:wger/widgets/nutrition/nutri_score_badge.dart';

class ScanReader extends StatelessWidget {
  const ScanReader();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ReaderWidget(
      onScan: (result) {
        // notes:
        // 1. even if result.isValid, result.error is always non-null (and set to "")
        // 2. i've never encountered scan errors to see when they occur, and
        //    i wouldn't know what to do about them anyway, so we simply return
        //    result.text in such case (which presumably will be null, or "")
        // 3. when user cancels (swipe left / back button) this code is no longer
        //    run and the caller receives null
        Navigator.pop(context, result.text);
      },
    ),
  );
}

class IngredientTypeahead extends ConsumerStatefulWidget {
  final _logger = Logger('IngredientTypeahead');

  final TextEditingController _ingredientController;
  final TextEditingController _ingredientIdController;

  final String barcode;
  final bool test;
  final bool showScanner;

  final Function(int id, String name, num? amount) selectIngredient;
  final Function() onDeselectIngredient;
  final Function(String query) onUpdateSearchQuery;

  IngredientTypeahead(
    this._ingredientIdController,
    this._ingredientController, {
    this.showScanner = true,
    this.test = false,
    this.barcode = '',
    required this.selectIngredient,
    required this.onDeselectIngredient,
    required this.onUpdateSearchQuery,
  });

  @override
  ConsumerState<IngredientTypeahead> createState() => _IngredientTypeaheadState();
}

class _IngredientTypeaheadState extends ConsumerState<IngredientTypeahead> {
  late String barcode;
  @override
  void initState() {
    super.initState();
    barcode = widget.barcode; // for unit tests
  }

  Future<String> openBarcodeScan(BuildContext context) async {
    try {
      final code = await Navigator.of(
        context,
      ).push<String?>(MaterialPageRoute(builder: (context) => const ScanReader()));

      if (code == null) {
        return '';
      }

      if (code == '-1') {
        return '';
      }
      return code;
    } on PlatformException catch (e) {
      widget._logger.warning('PlatformException during barcode scan: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(ingredientFiltersSyncProvider);
    return Column(
      children: [
        TypeAheadField<Ingredient>(
          controller: widget._ingredientController,
          debounceDuration: const Duration(milliseconds: 500),
          builder: (context, controller, focusNode) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return AppLocalizations.of(context).selectIngredient;
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: AppLocalizations.of(context).searchIngredient,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    filterButton(),
                    if (widget.showScanner && !isDesktop) scanButton(),
                  ],
                ),
              ),
            );
          },
          suggestionsCallback: (pattern) {
            // don't do search if user has already loaded a specific item
            if (pattern == '' || widget._ingredientIdController.text.isNotEmpty) {
              return null;
            }

            widget.onUpdateSearchQuery(pattern);
            widget.onDeselectIngredient();

            return legacy_provider.Provider.of<NutritionPlansProvider>(
              context,
              listen: false,
            ).searchIngredient(
              pattern,
              languageCode: Localizations.localeOf(context).languageCode,
              searchLanguage: filters.searchLanguage,
              isVegan: filters.isVegan,
              isVegetarian: filters.isVegetarian,
              nutriscoreMax: filters.nutriscoreMax,
            );
          },
          itemBuilder: (context, ingredient) {
            final i18n = AppLocalizations.of(context);
            final chips = <Widget>[];
            if (ingredient.isVegan == true) {
              chips.add(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    i18n.isVegan,
                    style: TextStyle(fontSize: 11, color: Colors.green[900]),
                  ),
                ),
              );
            } else if (ingredient.isVegetarian == true) {
              chips.add(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    i18n.isVegetarian,
                    style: TextStyle(fontSize: 11, color: Colors.green[900]),
                  ),
                ),
              );
            }
            if (ingredient.nutriscore != null) {
              chips.add(NutriScoreBadge(score: ingredient.nutriscore!, size: NutriScoreSize.small));
            }

            return ListTile(
              leading: ingredient.image != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(ingredient.thumbnails!.medium),
                    )
                  : const CircleIconAvatar(
                      Icon(Icons.image, color: Colors.grey),
                    ),
              title: Text(
                ingredient.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: chips.isNotEmpty ? Wrap(spacing: 4, runSpacing: 4, children: chips) : null,
              trailing: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  showIngredientDetails(
                    context,
                    ingredient.id,
                    select: () {
                      widget.selectIngredient(ingredient.id, ingredient.name, null);
                    },
                  );
                },
              ),
            );
          },
          transitionBuilder: (context, animation, child) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
            child: child,
          ),
          onSelected: (suggestion) async {
            // Cache selected ingredient
            final provider = legacy_provider.Provider.of<NutritionPlansProvider>(
              context,
              listen: false,
            );
            await provider.cacheIngredient(suggestion);
            widget.selectIngredient(suggestion.id, suggestion.name, null);
          },
        ),
      ],
    );
  }

  Widget scanButton() {
    return IconButton(
      key: const Key('scan-button'),
      icon: const FaIcon(FontAwesomeIcons.barcode),
      onPressed: () async {
        if (!widget.test) {
          barcode = await openBarcodeScan(context);
        }

        if (!mounted) {
          return;
        }
        showDialog(
          context: context,
          builder: (context) => FutureBuilder<Ingredient?>(
            future: legacy_provider.Provider.of<NutritionPlansProvider>(
              context,
              listen: false,
            ).searchIngredientWithBarcode(barcode),
            builder: (BuildContext context, AsyncSnapshot<Ingredient?> snapshot) {
              return IngredientScanResultDialog(snapshot, barcode, widget.selectIngredient);
            },
          ),
        );
      },
    );
  }

  /// The filter icon button — shows an active-filter badge and opens
  /// [IngredientFilterDialog] on tap.
  Widget filterButton() {
    final filters = ref.watch(ingredientFiltersSyncProvider);
    final languageCode = Localizations.localeOf(context).languageCode;

    // Auto-correct: in an English locale "current + English" collapses to
    // "current" — fix it once if a stored preference landed on the
    // non-locale-aware default.
    if (languageCode == LANGUAGE_SHORT_ENGLISH &&
        filters.searchLanguage == SearchLanguage.currentAndEnglish) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(ingredientFiltersProvider.notifier).chooseLanguage(SearchLanguage.current);
      });
    }

    final activeFilterCount = filters.activeFilterCount(languageCode);

    return IconButton(
      icon: Badge(
        label: Text('$activeFilterCount'),
        isLabelVisible: activeFilterCount > 0,
        child: const Icon(Icons.tune),
      ),
      onPressed: () => showDialog(
        context: context,
        builder: (_) => const IngredientFilterDialog(),
      ),
    );
  }
}

class IngredientAvatar extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientAvatar({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return ingredient.image != null
        ? GestureDetector(
            child: CircleAvatar(
              backgroundImage: NetworkImage(ingredient.image!.url),
            ),
            onTap: () async {
              if (ingredient.image!.objectUrl != '') {
                return launchURL(ingredient.image!.objectUrl, context);
              }
            },
          )
        : const CircleIconAvatar(Icon(Icons.image, color: Colors.grey));
  }
}
