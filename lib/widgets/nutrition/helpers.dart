/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/http_exception.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';

showNutritionalPlanSheet(BuildContext context, NutritionalPlan nutritionalPlan) async {
  final _form = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  descriptionController.text = nutritionalPlan.description ?? '';

  showModalBottomSheet(
    context: context,
    builder: (BuildContext ctx) {
      return Container(
        margin: EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            children: [
              Text(
                AppLocalizations.of(ctx).newNutritionalPlan,
                style: Theme.of(ctx).textTheme.headline6,
              ),

              // Description
              TextFormField(
                decoration: InputDecoration(labelText: AppLocalizations.of(ctx).description),
                controller: descriptionController,
                onFieldSubmitted: (_) {},
                onSaved: (newValue) {
                  nutritionalPlan.description = newValue;
                },
              ),
              ElevatedButton(
                child: Text(AppLocalizations.of(ctx).save),
                onPressed: () async {
                  // Validate and save the current values to the weightEntry
                  final isValid = _form.currentState.validate();
                  if (!isValid) {
                    return;
                  }
                  _form.currentState.save();

                  // Save the entry on the server
                  try {
                    if (nutritionalPlan.id != null) {
                      await Provider.of<Nutrition>(ctx, listen: false).patchPlan(nutritionalPlan);
                    } else {
                      await Provider.of<Nutrition>(ctx, listen: false).postPlan(nutritionalPlan);
                    }

                    // Saving was successful, reset the data
                    //descriptionController.clear();
                    //nutritionalPlan = NutritionalPlan();
                  } on WgerHttpException catch (error) {
                    showHttpExceptionErrorDialog(error, ctx);
                  } catch (error) {
                    showErrorDialog(error, context);
                  }
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
