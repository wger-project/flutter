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
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/nutritional_plans_list.dart';

class NutritionScreen extends StatefulWidget {
  static const routeName = '/nutrition';

  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  Widget getAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.nutritionalPlans),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar() as PreferredSizeWidget?,
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          showFormBottomSheet(
            context,
            AppLocalizations.of(context)!.newNutritionalPlan,
            PlanForm(),
          );
          //await showNutritionalPlanSheet(context, nutritionalPlan);
        },
      ),
      body: Consumer<Nutrition>(
        builder: (context, nutritionProvider, child) => NutritionalPlansList(nutritionProvider),
      ),
    );
  }
}
