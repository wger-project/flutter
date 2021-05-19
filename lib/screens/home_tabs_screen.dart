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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final _screenList = <Widget>[
    DashboardScreen(),
    WorkoutPlansScreen(),
    NutritionScreen(),
    WeightScreen(),
    GalleryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screenList.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: AppLocalizations.of(context).labelDashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: AppLocalizations.of(context).labelBottomNavWorkout,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: AppLocalizations.of(context).labelBottomNavNutrition,
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.weight,
              size: 20,
            ),
            label: AppLocalizations.of(context).weight,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: AppLocalizations.of(context).gallery,
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: wgerPrimaryColorLight,
        backgroundColor: wgerPrimaryColor,
        onTap: _onItemTapped,
        showUnselectedLabels: false,
      ),
    );
  }
}
