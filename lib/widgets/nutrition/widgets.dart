/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/helpers/platform.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/models/exercises/ingredient_api.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/nutrition/nutrition_tiles.dart';

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

class IngredientTypeahead extends StatefulWidget {
  final TextEditingController _ingredientController;
  final TextEditingController _ingredientIdController;

  final String barcode;
  final bool? test;
  final bool showScanner;

  final Function(int id, String name, num? amount) selectIngredient;
  final Function() unSelectIngredient;
  final Function(String query) updateSearchQuery;

  const IngredientTypeahead(
    this._ingredientIdController,
    this._ingredientController, {
    this.showScanner = true,
    this.test = false,
    this.barcode = '',
    required this.selectIngredient,
    required this.unSelectIngredient,
    required this.updateSearchQuery,
  });

  @override
  _IngredientTypeaheadState createState() => _IngredientTypeaheadState();
}

class _IngredientTypeaheadState extends State<IngredientTypeahead> {
  var _searchEnglish = true;
  late String barcode;

  @override
  void initState() {
    super.initState();
    barcode = widget.barcode; // for unit tests
  }

  Future<String> readerscan(BuildContext context) async {
    try {
      final code = await Navigator.of(context)
          .push<String?>(MaterialPageRoute(builder: (context) => const ScanReader()));
      if (code == null) {
        return '';
      }

      if (code.compareTo('-1') == 0) {
        return '';
      }
      return code;
    } on PlatformException {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TypeAheadField<IngredientApiSearchEntry>(
          controller: widget._ingredientController,
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
              onChanged: (value) {
                widget.updateSearchQuery(value);
                // unselect to start a new search
                widget.unSelectIngredient();
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: AppLocalizations.of(context).searchIngredient,
                suffixIcon: (widget.showScanner && !isDesktop) ? scanButton() : null,
              ),
            );
          },
          suggestionsCallback: (pattern) {
            // don't do search if user has already loaded a specific item
            if (pattern == '' || widget._ingredientIdController.text.isNotEmpty) {
              return null;
            }

            return Provider.of<NutritionPlansProvider>(context, listen: false).searchIngredient(
              pattern,
              languageCode: Localizations.localeOf(context).languageCode,
              searchEnglish: _searchEnglish,
            );
          },
          itemBuilder: (context, suggestion) {
            final url = context.read<NutritionPlansProvider>().baseProvider.auth.serverUrl;
            return ListTile(
              leading: suggestion.data.image != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(url! + suggestion.data.image!),
                    )
                  : const CircleIconAvatar(
                      Icon(Icons.image, color: Colors.grey),
                    ),
              title: Text(suggestion.value),
              // subtitle: Text(suggestion.data.id.toString()),
            );
          },
          transitionBuilder: (context, animation, child) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
            child: child,
          ),
          onSelected: (suggestion) {
            widget.selectIngredient(suggestion.data.id, suggestion.value, null);
          },
        ),
        if (Localizations.localeOf(context).languageCode != LANGUAGE_SHORT_ENGLISH)
          SwitchListTile(
            title: Text(AppLocalizations.of(context).searchNamesInEnglish),
            value: _searchEnglish,
            onChanged: (_) {
              setState(() {
                _searchEnglish = !_searchEnglish;
              });
            },
            dense: true,
          ),
      ],
    );
  }

  Widget scanButton() {
    return IconButton(
      key: const Key('scan-button'),
      icon: const FaIcon(FontAwesomeIcons.barcode),
      onPressed: () async {
        try {
          if (!widget.test!) {
            barcode = await readerscan(context);
          }

          if (barcode.isNotEmpty) {
            if (!mounted) {
              return;
            }
            final result = await Provider.of<NutritionPlansProvider>(
              context,
              listen: false,
            ).searchIngredientWithCode(barcode);
            // TODO: show spinner...
            if (!mounted) {
              return;
            }

            if (result != null) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  key: const Key('found-dialog'),
                  title: Text(AppLocalizations.of(context).productFound),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppLocalizations.of(context).productFoundDescription(result.name)),
                      MealItemValuesTile(
                        ingredient: result,
                        nutritionalValues: result.nutritionalValues,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      key: const Key('found-dialog-confirm-button'),
                      child: Text(MaterialLocalizations.of(context).continueButtonLabel),
                      onPressed: () {
                        widget.selectIngredient(result.id, result.name, null);
                        Navigator.of(ctx).pop();
                      },
                    ),
                    TextButton(
                      key: const Key('found-dialog-close-button'),
                      child: Text(
                        MaterialLocalizations.of(context).closeButtonLabel,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              );
            } else {
              //nothing is matching barcode
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  key: const Key('notFound-dialog'),
                  title: Text(AppLocalizations.of(context).productNotFound),
                  content: Text(
                    AppLocalizations.of(context).productNotFoundDescription(barcode),
                  ),
                  actions: [
                    TextButton(
                      key: const Key('notFound-dialog-close-button'),
                      child: Text(
                        MaterialLocalizations.of(context).closeButtonLabel,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            showErrorDialog(e, context);
          }
        }
      },
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
              backgroundImage: NetworkImage(ingredient.image!.image),
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
