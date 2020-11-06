import 'package:flutter/material.dart';
import 'package:wger/providers/workout_plan.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/workout_plan_detail.dart';

class WorkoutPlanScreen extends StatefulWidget {
  static const routeName = '/workout-plan-detail';

  @override
  _WorkoutPlanScreenState createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  Widget getAppBar() {
    return AppBar(
      title: Text('Workout plan'),
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
    final workoutPlan =
        ModalRoute.of(context).settings.arguments as WorkoutPlan;
    return Scaffold(
      appBar: getAppBar(),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: WorkoutPlansDetail(workoutPlan),
    );
  }
}
