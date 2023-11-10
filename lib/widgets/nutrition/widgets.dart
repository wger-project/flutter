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
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/platform.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/core/core.dart';

class ScanReader extends StatelessWidget {
  String? scannedr;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ReaderWidget(
          onScan: (result) {
            scannedr = result.text;
            Navigator.pop(context, scannedr);
          },
        ),
      );
}

class IngredientTypeahead extends StatefulWidget {
  final TextEditingController _ingredientController;
  final TextEditingController _ingredientIdController;

  String? barcode = '';
  //Code? result;

  late final bool? test;
  final bool showScanner;

  IngredientTypeahead(
    this._ingredientIdController,
    this._ingredientController, {
    this.showScanner = true,
    this.test = false,
    this.barcode = '',
  });

  @override
  _IngredientTypeaheadState createState() => _IngredientTypeaheadState();
}

class _IngredientTypeaheadState extends State<IngredientTypeahead> {
  var _searchEnglish = true;

  Future<String> readerscan(BuildContext context) async {
    String scannedcode;
    try {
      scannedcode =
          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ScanReader()));

      if (scannedcode.compareTo('-1') == 0) {
        return '';
      }
    } on PlatformException {
      return '';
    }

    return scannedcode;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: widget._ingredientController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: AppLocalizations.of(context).searchIngredient,
              suffixIcon: (widget.showScanner && !isDesktop) ? scanButton() : null,
            ),
          ),
          suggestionsCallback: (pattern) async {
            return Provider.of<NutritionPlansProvider>(context, listen: false).searchIngredient(
              pattern,
              languageCode: Localizations.localeOf(context).languageCode,
              searchEnglish: _searchEnglish,
            );
          },
          itemBuilder: (context, dynamic suggestion) {
            final url = context.read<NutritionPlansProvider>().baseProvider.auth.serverUrl;
            return ListTile(
              leading: suggestion['data']['image'] != null
                  ? CircleAvatar(backgroundImage: NetworkImage(url! + suggestion['data']['image']))
                  : const CircleIconAvatar(Icon(Icons.image, color: Colors.grey)),
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
      onPressed: () async {
        try {
          if (!widget.test!) {
            widget.barcode = await readerscan(context);
          }

          if (widget.barcode!.isNotEmpty) {
            final result = await Provider.of<NutritionPlansProvider>(context, listen: false)
                .searchIngredientWithCode(widget.barcode!);

            if (result != null) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  key: const Key('found-dialog'),
                  title: Text(AppLocalizations.of(context).productFound),
                  content: Text(AppLocalizations.of(context).productFoundDescription(result.name)),
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
                    AppLocalizations.of(context).productNotFoundDescription(widget.barcode!),
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
          if (context.mounted) {
            showErrorDialog(e, context);
            // Need to pop back since reader scan is a widget
            // otherwise returns null when back button is pressed
            return Navigator.pop(context);
          }
        }
      },
      icon: const FaIcon(FontAwesomeIcons.barcode),
    );
  }
}
