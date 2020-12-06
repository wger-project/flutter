/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/models/http_exception.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/weight/entries_list.dart';

class WeightScreen extends StatefulWidget {
  static const routeName = '/weight';

  @override
  _WeightScreenState createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  Future<void> _refreshWeightEntries(BuildContext context) async {
    await Provider.of<BodyWeight>(context, listen: false).fetchAndSetEntries();
  }

  final dateController = TextEditingController(text: toDate(DateTime.now()).toString());
  final weightController = TextEditingController();
  WeightEntry weightEntry = WeightEntry();
  final _form = GlobalKey<FormState>();

  Widget getAppBar() {
    return AppBar(
      title: Text('Weight'),
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
        child: const Icon(Icons.add),
        onPressed: () async {
          await showWeightEntrySheet(context);
        },
      ),
      body: FutureBuilder(
        future: _refreshWeightEntries(context),
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _refreshWeightEntries(context),
                child: Consumer<BodyWeight>(
                  builder: (context, productsData, child) => WeightEntriesList(),
                ),
              ),
      ),
    );
  }

  showWeightEntrySheet(BuildContext context) async {
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
                    AppLocalizations.of(ctx).newEntry,
                    style: Theme.of(ctx).textTheme.headline6,
                  ),

                  // Weight date
                  TextFormField(
                    decoration: InputDecoration(labelText: AppLocalizations.of(ctx).date),
                    controller: dateController,
                    onTap: () async {
                      // Stop keyboard from appearing
                      FocusScope.of(ctx).requestFocus(new FocusNode());

                      // Show Date Picker Here
                      var pickedDate = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 10),
                        lastDate: DateTime.now(),
                      );

                      dateController.text = toDate(pickedDate);
                    },
                    onSaved: (newValue) {
                      weightEntry.date = DateTime.parse(newValue);
                    },
                    onFieldSubmitted: (_) {},
                  ),

                  // Weight
                  TextFormField(
                    decoration: InputDecoration(labelText: AppLocalizations.of(ctx).weight),
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (_) {},
                    onSaved: (newValue) {
                      weightEntry.weight = double.parse(newValue);
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
                        await Provider.of<BodyWeight>(ctx, listen: false).addEntry(weightEntry);

                        // Saving was successful, reset the data
                        weightController.clear();
                        dateController.clear();
                        weightEntry = WeightEntry();
                      } on WgerHttpException catch (error) {
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
