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
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/providers/nutrition.dart';

class IngredientTypeahead extends StatefulWidget {
  final TextEditingController _ingredientController;
  final TextEditingController _ingredientIdController;
  late String? _barcode;
  late final bool? _test;
  final bool _showScanner;

  IngredientTypeahead(this._ingredientIdController, this._ingredientController, this._showScanner,
      [this._barcode, this._test]);

  @override
  _IngredientTypeaheadState createState() => _IngredientTypeaheadState();
}

Future<String> scanBarcode(BuildContext context) async {
  String barcode;
  try {
    barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', AppLocalizations.of(context).close, true, ScanMode.BARCODE);
    if (barcode.compareTo('-1') == 0) {
      return '';
    }
  } on PlatformException {
    return '';
  }

  return barcode;
}

class _IngredientTypeaheadState extends State<IngredientTypeahead> {
  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: widget._ingredientController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          labelText: AppLocalizations.of(context).searchIngredient,
          suffixIcon: widget._showScanner ? scanButton() : null,
        ),
      ),
      suggestionsCallback: (pattern) async {
        return Provider.of<NutritionPlansProvider>(context, listen: false).searchIngredient(
          pattern,
          Localizations.localeOf(context).languageCode,
        );
      },
      itemBuilder: (context, dynamic suggestion) {
        return ListTile(
          title: Text(suggestion['value']),
          subtitle: Text(suggestion['data']['id'].toString()),
        );
      },
      transitionBuilder: (context, suggestionsBox, controller) {
        return suggestionsBox;
      },
      onSuggestionSelected: (dynamic suggestion) {
        widget._ingredientIdController.text = suggestion['data']['id'].toString();
        widget._ingredientController.text = suggestion['value'];
      },
      validator: (value) {
        if (value!.isEmpty) {
          return AppLocalizations.of(context).selectIngredient;
        }
        return null;
      },
    );
  }

  Widget scanButton() {
    return IconButton(
        key: const Key('scan-button'),
        onPressed: () async {
          try {
            if (!widget._test!) {
              widget._barcode = await scanBarcode(context);
            }

            if (widget._barcode!.isNotEmpty) {
              final result = await Provider.of<NutritionPlansProvider>(context, listen: false)
                  .searchIngredientWithCode(widget._barcode!);

              if (result != null) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    key: const Key('found-dialog'),
                    title: Text(AppLocalizations.of(context).productFound),
                    content:
                        Text(AppLocalizations.of(context).productFoundDescription(result.name)),
                    actions: [
                      TextButton(
                        key: const Key('found-dialog-confirm-button'),
                        child: Text(MaterialLocalizations.of(context).continueButtonLabel),
                        onPressed: () {
                          widget._ingredientController.text = result.name;
                          widget._ingredientIdController.text = result.id.toString();
                          Navigator.of(ctx).pop();
                        },
                      ),
                      TextButton(
                        key: const Key('found-dialog-close-button'),
                        child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      )
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
                      AppLocalizations.of(context).productNotFoundDescription(widget._barcode!),
                    ),
                    actions: [
                      TextButton(
                        key: const Key('notFound-dialog-close-button'),
                        child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      )
                    ],
                  ),
                );
              }
            }
          } catch (e) {
            showErrorDialog(e, context);
          }
        },
        icon: Image.asset('assets/images/barcode_scanner_icon.png'));
  }
}
