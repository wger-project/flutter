/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:wger/screens/dashboard.dart';
import 'package:wger/screens/gallery_screen.dart';
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
  TabController? controller;

  @override
  initState() {
    super.initState();
    controller = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: <Widget>[
          DashboardScreen(),
          GalleryScreen(),
          WorkoutPlansScreen(),
          NutritionScreen(),
          WeightScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        color: wgerPrimaryColor,
        child: TabBar(
          controller: controller,
          indicatorColor: wgerSecondaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: wgerPrimaryColorLight,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.dashboard),
            ),
            Tab(
              icon: Icon(Icons.photo_library),
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
      ),
    );
  }
}
