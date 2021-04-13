/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/screens/workout_plan_screen.dart';

class WorkoutPlansList extends StatelessWidget {
  final WorkoutPlans _workoutProvider;

  WorkoutPlansList(this._workoutProvider);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: _workoutProvider.items.length,
      itemBuilder: (context, index) {
        final currentWorkout = _workoutProvider.items[index];
        return Dismissible(
          key: Key(currentWorkout.id.toString()),
          confirmDismiss: (direction) async {
            // Delete workout from DB
            final bool res = await showDialog(
                context: context,
                builder: (BuildContext contextDialog) {
                  return AlertDialog(
                    content: Text(
                      AppLocalizations.of(context)!.confirmDelete(currentWorkout.description),
                    ),
                    actions: [
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.cancel),
                        onPressed: () => Navigator.of(contextDialog).pop(),
                      ),
                      TextButton(
                        child: Text(
                          AppLocalizations.of(context)!.delete,
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                        onPressed: () {
                          // Confirmed, delete the workout
                          Provider.of<WorkoutPlans>(context, listen: false)
                              .deleteWorkout(currentWorkout.id!);

                          // Close the popup
                          Navigator.of(contextDialog).pop();

                          // and inform the user
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.successfullyDeleted,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                });
            return res;
          },
          background: Container(
            color: Theme.of(context).errorColor,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            margin: EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 4,
            ),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          direction: DismissDirection.endToStart,
          child: Card(
            child: ListTile(
              onTap: () {
                _workoutProvider.setCurrentPlan(currentWorkout.id!);

                Navigator.of(context)
                    .pushNamed(WorkoutPlanScreen.routeName, arguments: currentWorkout);
              },
              title: Text(currentWorkout.description),
              subtitle: Text(
                DateFormat.yMd(Localizations.localeOf(context).languageCode)
                    .format(currentWorkout.creationDate),
              ),
            ),
          ),
        );
      },
    );
  }
}
