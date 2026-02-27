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
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/helpers/platform.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/nutrition/ingredient.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/nutrition/helpers.dart';
import 'package:wger/widgets/nutrition/ingredient_dialogs.dart';

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
  _IngredientTypeaheadState createState() => _IngredientTypeaheadState();
}

class _IngredientTypeaheadState extends State<IngredientTypeahead> {
  late String barcode;
  var _searchEnglish = true;
  var _isVegan = false;
  var _isVegetarian = false;

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

            return Provider.of<NutritionPlansProvider>(context, listen: false).searchIngredient(
              pattern,
              languageCode: Localizations.localeOf(context).languageCode,
              searchEnglish: _searchEnglish,
              isVegan: _isVegan,
              isVegetarian: _isVegetarian,
            );
          },
          itemBuilder: (context, ingredient) {
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
            final provider = Provider.of<NutritionPlansProvider>(context, listen: false);
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
            future: Provider.of<NutritionPlansProvider>(
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

  Widget filterButton() {
    final i18n = AppLocalizations.of(context);

    return IconButton(
      icon: const Icon(Icons.tune),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: Text(i18n.filter),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (Localizations.localeOf(context).languageCode != LANGUAGE_SHORT_ENGLISH)
                        SwitchListTile(
                          title: Text(i18n.searchNamesInEnglish),
                          value: _searchEnglish,
                          onChanged: (val) {
                            setDialogState(() {
                              _searchEnglish = val;
                            });
                          },
                        ),
                      SwitchListTile(
                        title: Text(i18n.isVegan),
                        value: _isVegan,
                        onChanged: (val) {
                          setDialogState(() {
                            _isVegan = val;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: Text(i18n.isVegetarian),
                        value: _isVegetarian,
                        onChanged: (val) {
                          setDialogState(() {
                            _isVegetarian = val;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                    ),
                  ],
                );
              },
            );
          },
        );
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
