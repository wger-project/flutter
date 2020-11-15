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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Center(
            child: Text("dashboard content here"),
          ),
          FlatButton(
            child: Text('reload'),
            onPressed: () {
              Provider.of<Exercises>(context, listen: false).fetchAndSetExercises();
            },
          ),
          FutureBuilder(
            future: Provider.of<Exercises>(context, listen: false).fetchAndSetExercises(),
            builder: (ctx, authResultSnapshot) =>
                authResultSnapshot.connectionState == ConnectionState.waiting
                    ? Center(child: CircularProgressIndicator())
                    : Text("all exercises loaded"),
          ),
        ],
      ),
    );
  }
}
