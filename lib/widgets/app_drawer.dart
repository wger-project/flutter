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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/providers/auth.dart';
import 'package:wger/screens/dashboard.dart';
import 'package:wger/screens/nutrition_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/screens/workout_plans_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('wger'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text(AppLocalizations.of(context).labelDashboard),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Training'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(WorkoutPlansScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.fastfood),
            title: Text('Nutrition'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(NutritionScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Weight'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(WeightScreen.routeName);
            },
          ),
          Divider(),
          Expanded(child: Container()),
          ListTile(
            dense: true,
            leading: Icon(Icons.edit),
            title: Text('Options'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text("Would show options dialog"),
                  actions: [
                    TextButton(
                      child: Text(
                        "Close",
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Provider.of<Auth>(context, listen: false).logout();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          AboutListTile(
            dense: true,
            icon: Icon(Icons.info),
            applicationName: 'wger',
            applicationVersion: '0.0.1 alpha',
            applicationLegalese: '\u{a9} 2020 The wger team',
            applicationIcon: Image.asset(
              'assets/images/logo.png',
              width: 60,
            ),
            aboutBoxChildren: [
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, '
                          'sed diam nonumy eirmod tempor invidunt ut labore et dolore '
                          'magna aliquyam erat, sed diam voluptua. At vero eos et accusam '
                          'et justo duo dolores et ea rebum.\n',
                    ),
                    TextSpan(
                      text: 'https://github.com/wger-project/wger',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch('https://github.com/wger-project/wger');
                        },
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
