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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wger/providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context, listen: false);

    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('wger'),
            automaticallyImplyLeading: false,
          ),
          /*
          ListTile(
            leading: Icon(Icons.home),
            title: Text(AppLocalizations.of(context)!.labelDashboard),
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

           */
          /*
          ListTile(
            //dense: true,
            leading: Icon(Icons.build),
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
          */
          ListTile(
            //dense: true,
            leading: Icon(Icons.exit_to_app),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () {
              Provider.of<Auth>(context, listen: false).logout();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          AboutListTile(
            //dense: true,
            icon: Icon(Icons.info),
            applicationName: 'wger',
            applicationVersion: '${authProvider.applicationVersion!.version} '
                '(server: ${authProvider.serverVersion})',
            applicationLegalese: '\u{a9} 2020 - 2021 contributors',
            applicationIcon: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.asset(
                'assets/images/logo.png',
                width: 60,
              ),
            ),
            aboutBoxChildren: [
              SizedBox(
                height: 10,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.aboutText,
                    ),
                    TextSpan(
                      text: 'https://github.com/wger-project',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launch('https://github.com/wger-project');
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
