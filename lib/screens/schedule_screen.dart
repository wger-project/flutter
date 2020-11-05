import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/workout_plans_list.dart';

class ScheduleScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  var _isLoading = false;
  var _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<WorkoutPlans>(context).fetchAndSetWorkouts().then((value) {
        _isLoading = false;
      });
    }
    _isInit = false;
  }

  Widget getAppBar() {
    return AppBar(
      title: Text('Workouts'),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : WorkoutPlansList(),
    );
  }
}
