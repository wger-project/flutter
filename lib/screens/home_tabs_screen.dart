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
import 'package:wger/screens/dashboard.dart';
import 'package:wger/screens/nutritional_plans_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/screens/workout_plans_screen.dart';
import 'package:wger/theme/theme.dart';

class HomeTabsScreen extends StatefulWidget {
  static const routeName = '/dashboard2';

  @override
  _HomeTabsScreenState createState() => _HomeTabsScreenState();
}

class _HomeTabsScreenState extends State<HomeTabsScreen> with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  initState() {
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: <Widget>[
          DashboardScreen(),
          WorkoutPlansScreen(),
          NutritionScreen(),
          WeightScreen(),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: controller,
        indicatorColor: wgerSecondaryColor,
        labelColor: Colors.black,
        tabs: <Widget>[
          Tab(
            icon: Icon(Icons.dashboard),
          ),
          Tab(
            icon: Icon(Icons.fitness_center),
          ),
          Tab(
            icon: Icon(Icons.restaurant),
          ),
          Tab(
            icon: Icon(Icons.bar_chart),
          ),
        ],
      ),
    );
  }
}
