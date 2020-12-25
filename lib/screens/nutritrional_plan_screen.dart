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
import 'package:provider/provider.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutrition.dart';
import 'package:wger/widgets/nutrition/nutritional_plan_detail.dart';

class NutritrionalPlanScreen extends StatefulWidget {
  static const routeName = '/nutritional-plan-detail';

  @override
  _NutritrionalPlanScreenState createState() => _NutritrionalPlanScreenState();
}

class _NutritrionalPlanScreenState extends State<NutritrionalPlanScreen> {
  Future<NutritionalPlan> _loadNutritionalPlanDetail(BuildContext context, int planId) async {
    var plan = await Provider.of<Nutrition>(context, listen: false).findById(planId);
    return plan;
  }

  Widget getAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context).nutritionalPlan),
      actions: [
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text("Would open options"),
                actions: [
                  TextButton(
                    child: Text(
                      "Cancel",
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final nutritionalPlan = ModalRoute.of(context).settings.arguments as NutritionalPlan;
    print(nutritionalPlan.nutritionalValues);

    return Scaffold(
      appBar: getAppBar(),
      //drawer: AppDrawer(),
      body: FutureBuilder<NutritionalPlan>(
        future: _loadNutritionalPlanDetail(context, nutritionalPlan.id),
        builder: (context, AsyncSnapshot<NutritionalPlan> snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _loadNutritionalPlanDetail(context, nutritionalPlan.id),
                    child: Consumer<Nutrition>(
                      builder: (context, workout, _) => NutritionalPlanDetailWidget(snapshot.data),
                    ),
                  ),
      ),
    );
  }
}
