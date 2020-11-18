import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutritional_plans.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/nutrition/nutritional_plans_list.dart';

class NutritionScreen extends StatelessWidget {
  static const routeName = '/nutrition';

  Future<void> _refreshPlans(BuildContext context) async {
    await Provider.of<NutritionalPlans>(context, listen: false).fetchAndSetPlans();
  }

  Widget getAppBar() {
    return AppBar(
      title: Text('Nutrition'),
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
          Provider.of<NutritionalPlans>(context, listen: false).addPlan(
            NutritionalPlan(description: 'button'),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _refreshPlans(context),
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _refreshPlans(context),
                child: Consumer<WorkoutPlans>(
                  builder: (context, productsData, child) => NutritionalPlansList(),
                ),
              ),
      ),
    );
  }
}
