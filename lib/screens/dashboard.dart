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
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Widget getAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context).labelDashboard),
      actions: [
        IconButton(
          icon: Icon(Icons.bar_chart),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget getWorkoutCard() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.fitness_center),
            title: Text('Something to do with workouts'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monday'),
                Text('Tuesday'),
                Text('Wednesday'),
                Text('Thursday'),
                Text('Friday'),
                Text('Saturday'),
                Text('Sunday'),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('Action one'),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              TextButton(
                child: const Text('Action two'),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget getNutritionCard() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.fitness_center),
            title: Text('Nutrition'),
            subtitle: Text('Nutrition overview, graphs, etc'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('Action one'),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              TextButton(
                child: const Text('Action two'),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget getWeightCard() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.restaurant),
            title: Text('Weight'),
            subtitle: Text('Weight overview, graphs, etc'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                child: const Text('Action one'),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              TextButton(
                child: const Text('Action two'),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      drawer: AppDrawer(),
      body: Column(
        children: [
          getWorkoutCard(),
          getNutritionCard(),
          getWeightCard(),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FutureBuilder(
                future: Provider.of<Exercises>(context, listen: false).fetchAndSetExercises(),
                builder: (ctx, authResultSnapshot) =>
                    authResultSnapshot.connectionState == ConnectionState.waiting
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Initialising exercise database...'),
                              LinearProgressIndicator(),
                            ],
                          )
                        : Text("all exercises loaded"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
