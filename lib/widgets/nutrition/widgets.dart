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
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/nutrition.dart';

class IngredientTypeahead extends StatefulWidget {
  final TextEditingController _ingredientController;
  final TextEditingController _ingredientIdController;

  IngredientTypeahead(this._ingredientIdController, this._ingredientController);

  @override
  _IngredientTypeaheadState createState() => _IngredientTypeaheadState();
}

class _IngredientTypeaheadState extends State<IngredientTypeahead> {
  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: widget._ingredientController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).searchIngredient,
          suffixIcon: const Icon(Icons.search),
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
}
