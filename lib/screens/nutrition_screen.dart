import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/http_exception.dart';
import 'package:wger/models/nutrition/nutritional_plan.dart';
import 'package:wger/providers/nutritional_plans.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/nutrition/nutritional_plans_list.dart';

class NutritionScreen extends StatefulWidget {
  static const routeName = '/nutrition';

  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  Future<void> _refreshPlans(BuildContext context) async {
    await Provider.of<NutritionalPlans>(context, listen: false).fetchAndSetPlans();
  }

  final descriptionController = TextEditingController();
  NutritionalPlan nutritionalPlan = NutritionalPlan();
  final _form = GlobalKey<FormState>();

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
        onPressed: () async {
          await showNutritionalPlanSheet(context);
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

  showNutritionalPlanSheet(BuildContext context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return Container(
            margin: EdgeInsets.all(20),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(ctx).newNutritionalPlan,
                    style: Theme.of(ctx).textTheme.headline6,
                  ),

                  // Weight
                  TextFormField(
                    decoration: InputDecoration(labelText: AppLocalizations.of(ctx).description),
                    controller: descriptionController,
                    onFieldSubmitted: (_) {},
                    onSaved: (newValue) {
                      nutritionalPlan.description = newValue;
                    },
                  ),
                  ElevatedButton(
                    child: Text(AppLocalizations.of(ctx).save),
                    onPressed: () async {
                      // Validate and save the current values to the weightEntry
                      final isValid = _form.currentState.validate();
                      if (!isValid) {
                        return;
                      }
                      _form.currentState.save();

                      // Save the entry on the server
                      try {
                        await Provider.of<NutritionalPlans>(ctx, listen: false)
                            .addPlan(nutritionalPlan);

                        // Saving was successful, reset the data
                        descriptionController.clear();
                        nutritionalPlan = NutritionalPlan();
                      } on HttpException catch (error) {
                        showHttpExceptionErrorDialog(error, ctx);
                      } catch (error) {
                        showErrorDialog(error, context);
                      }
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
