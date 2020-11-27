import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/workouts/workout_plan_detail.dart';

class WorkoutPlanScreen extends StatefulWidget {
  static const routeName = '/workout-plan-detail';

  @override
  _WorkoutPlanScreenState createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  Future<WorkoutPlan> _loadWorkoutPlanDetail(BuildContext context, int workoutId) async {
    var workout =
        await Provider.of<WorkoutPlans>(context, listen: false).fetchAndSetFullWorkout(workoutId);
    return workout;
  }

  Widget getAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context).labelWorkoutPlan),
      actions: [
        IconButton(
          icon: Icon(Icons.bar_chart),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text("Would open weight log form"),
                actions: [
                  FlatButton(
                    child: Text(
                      "Cancel",
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutPlan = ModalRoute.of(context).settings.arguments as WorkoutPlan;

    return Scaffold(
      appBar: getAppBar(),
      //drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.play_arrow),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text("Would start gym mode"),
              actions: [
                FlatButton(
                  child: Text(
                    "Cancel",
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
      ),
      body: FutureBuilder<WorkoutPlan>(
        future: _loadWorkoutPlanDetail(context, workoutPlan.id),
        builder: (context, AsyncSnapshot<WorkoutPlan> snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _loadWorkoutPlanDetail(context, workoutPlan.id),
                    child: Consumer<WorkoutPlans>(
                      builder: (context, workout, _) => WorkoutPlanDetail(snapshot.data),
                    ),
                  ),
      ),
    );
  }
}
