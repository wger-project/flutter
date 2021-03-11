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
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/core/bottom_sheet.dart';
import 'package:wger/widgets/nutrition/forms.dart';
import 'package:wger/widgets/nutrition/nutritional_plan_detail.dart';

enum NutritionalPlanOptions {
  edit,
  delete,
  toggleMode,
}

class NutritionalPlanScreen extends StatelessWidget {
  static const routeName = '/nutritional-plan-detail';

  @override
  Widget build(BuildContext context) {
    final _nutritionalPlan = ModalRoute.of(context).settings.arguments as NutritionalPlan;

    return Scaffold(
      //appBar: getAppBar(nutritionalPlan),
      //drawer: AppDrawer(),
      body: Consumer<Nutrition>(
        builder: (context, nutrition, _) => CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              actions: [
                PopupMenuButton<NutritionalPlanOptions>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) {
                    // Edit
                    if (value == NutritionalPlanOptions.edit) {
                      showFormBottomSheet(
                        context,
                        AppLocalizations.of(context).edit,
                        PlanForm(_nutritionalPlan),
                      );

                      // Delete
                    } else if (value == NutritionalPlanOptions.delete) {
                      Provider.of<Nutrition>(context, listen: false)
                          .deletePlan(_nutritionalPlan.id);
                      Navigator.of(context).pushNamed(NutritionalPlanScreen.routeName);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<NutritionalPlanOptions>(
                        value: NutritionalPlanOptions.edit,
                        child: Text(AppLocalizations.of(context).edit),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<NutritionalPlanOptions>(
                        value: NutritionalPlanOptions.delete,
                        child: Text(AppLocalizations.of(context).delete),
                      ),
                    ];
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(_nutritionalPlan.description),
                background: Image(
                  image: AssetImage('assets/images/backgrounds/nutritional_plans.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            NutritionalPlanDetailWidget(_nutritionalPlan),
          ],
        ),
      ),
    );
  }
}
