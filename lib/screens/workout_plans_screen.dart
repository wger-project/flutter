import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/workouts/workout_plan.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/workout_plan_screen.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/workouts/workout_plans_list.dart';

class WorkoutPlansScreen extends StatefulWidget {
  static const routeName = '/workout-plans-list';

  @override
  _WorkoutPlansScreenState createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  final workoutController = TextEditingController();

  Future<WorkoutPlan> _refreshWorkoutPlans(BuildContext context) async {
    await Provider.of<WorkoutPlans>(context, listen: false).fetchAndSetWorkouts();
  }

  Widget getAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context).labelWorkoutPlans),
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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                margin: EdgeInsets.all(20),
                child: Form(
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context).newWorkout,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: AppLocalizations.of(context).description),
                        controller: workoutController,
                        onFieldSubmitted: (_) {},
                      ),
                      ElevatedButton(
                        child: Text('Save'),
                        onPressed: () {
                          final workoutFuture = Provider.of<WorkoutPlans>(context, listen: false)
                              .addWorkout(WorkoutPlan(description: workoutController.text));
                          workoutController.text = '';
                          Navigator.of(context).pop();
                          workoutFuture.then(
                            (workout) => Navigator.of(context).pushNamed(
                              WorkoutPlanScreen.routeName,
                              arguments: workout,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _refreshWorkoutPlans(context),
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _refreshWorkoutPlans(context),
                child: Consumer<WorkoutPlans>(
                  builder: (context, productsData, child) => WorkoutPlansList(),
                ),
              ),
      ),
    );
  }
}
