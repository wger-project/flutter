import 'package:flutter/material.dart';

import '../../models/measurements/measurement_category.dart';
import '../../screens/form_screen.dart';
import '../../screens/measurement_entries_screen.dart';
import '../core/charts.dart';
import 'forms.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoriesCard extends StatelessWidget {
  MeasurementCategory currentCategory;
  double? elevation;

  CategoriesCard(this.currentCategory, {this.elevation});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              currentCategory.name,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),

          // #FIXME  : Measurements Dashboard (Custom color set )
          Container(
            color: Color.fromARGB(255, 159, 114, 211),
            padding: const EdgeInsets.all(10),
            height: 220,
            child: MeasurementChartWidget(
              currentCategory.entries.map((e) => MeasurementChartEntry(e.value, e.date)).toList(),
              unit: currentCategory.unit,
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton(
                  child: Text(AppLocalizations.of(context).goToDetailPage),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      MeasurementEntriesScreen.routeName,
                      arguments: currentCategory.id,
                    );
                  }),
              IconButton(
                onPressed: () async {
                  await Navigator.pushNamed(
                    context,
                    FormScreen.routeName,
                    arguments: FormScreenArguments(
                      AppLocalizations.of(context).newEntry,
                      MeasurementEntryForm(currentCategory.id!),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
