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
          Divider(),
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
          ListTile(
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
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Provider.of<Auth>(context, listen: false).logout();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          AboutListTile(
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
