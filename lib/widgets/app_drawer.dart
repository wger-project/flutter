import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(WeightScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
