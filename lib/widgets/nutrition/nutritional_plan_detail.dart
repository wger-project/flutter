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
import 'package:intl/intl.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/meal.dart';

class NutritionalPlanDetailWidget extends StatefulWidget {
  NutritionalPlan _nutritionalPlan;
  NutritionalPlanDetailWidget(this._nutritionalPlan);

  @override
  _NutritionalPlanDetailWidgetState createState() => _NutritionalPlanDetailWidgetState();
}

class _NutritionalPlanDetailWidgetState extends State<NutritionalPlanDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                DateFormat('dd.MM.yyyy').format(widget._nutritionalPlan.creationDate).toString(),
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                widget._nutritionalPlan.description,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            ...widget._nutritionalPlan.meals.map((meal) => MealWidget(meal)).toList(),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).add),
              onPressed: () {
                showFormBottomSheet(context, 'Add meal form', MealForm(widget._nutritionalPlan));
              },
            ),
          ],
        ),
      ),
    );
  }
}
