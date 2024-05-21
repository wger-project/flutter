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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/platform.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/models/exercises/ingredient_api.dart';
import 'package:wger/models/nutrition/log.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/nutrition/helpers.dart';

class ScanReader extends StatelessWidget {
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
    try {
      final code = await Navigator.of(context)
          .push<String?>(MaterialPageRoute(builder: (context) => ScanReader()));
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
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: AppLocalizations.of(context).searchIngredient,
                suffixIcon: (widget.showScanner && !isDesktop) ? scanButton() : null,
              ),
            );
          },
          suggestionsCallback: (pattern) {
            if (pattern == '') {
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
                  ? CircleAvatar(backgroundImage: NetworkImage(url! + suggestion.data.image!))
                  : const CircleIconAvatar(Icon(Icons.image, color: Colors.grey)),
              title: Text(suggestion.value),
              // subtitle: Text(suggestion.data.id.toString()),
            );
          },
          transitionBuilder: (context, animation, child) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
            child: child,
          ),
          onSelected: (suggestion) {
            //SuggestionsController.of(context).;

            widget._ingredientIdController.text = suggestion.data.id.toString();
            widget._ingredientController.text = suggestion.value;
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
            widget.barcode = await readerscan(context);
          }

          if (widget.barcode!.isNotEmpty) {
            final result = await Provider.of<NutritionPlansProvider>(context, listen: false)
                .searchIngredientWithCode(widget.barcode!);
            if (!mounted) {
              return;
            }

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
          if (mounted) {
            showErrorDialog(e, context);
          }
        }
      },
    );
  }
}

class NutritionDiaryheader extends StatelessWidget {
  final Widget? leading;

  const NutritionDiaryheader({this.leading});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading ??
          const CircleIconAvatar(
            Icon(Icons.image, color: Colors.transparent),
            color: Colors.transparent,
          ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          AppLocalizations.of(context).energy,
          AppLocalizations.of(context).protein,
          AppLocalizations.of(context).carbohydrates,
          AppLocalizations.of(context).fat
        ]
            .map((e) => MutedText(
                  e,
                  textAlign: TextAlign.right,
                ))
            .toList(),
      ),
    );
  }
}

class NutritionDiaryEntry extends StatelessWidget {
  const NutritionDiaryEntry({
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
              icon: const Icon(Icons.delete_outline)),
      ],
    );
  }
}
