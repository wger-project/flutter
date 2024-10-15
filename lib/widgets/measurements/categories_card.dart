import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:wger/models/measurements/measurement_category.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/measurement_entries_screen.dart';
import 'package:wger/widgets/measurements/helpers.dart';
import 'charts.dart';
import 'forms.dart';

class CategoriesCard extends StatelessWidget {
  final MeasurementCategory currentCategory;
  final double? elevation;

  const CategoriesCard(this.currentCategory, {this.elevation});

  @override
  Widget build(BuildContext context) {
    final (entriesAll, entries7dAvg) = sensibleRange(
      currentCategory.entries.map((e) => MeasurementChartEntry(e.value, e.date)).toList(),
    );

    return Card(
      elevation: elevation,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              currentCategory.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            height: 220,
            child: MeasurementChartWidgetFl(
              entriesAll,
              currentCategory.unit,
              avgs: entries7dAvg,
            ),
          ),
          MeasurementOverallChangeWidget(
            entries7dAvg.first,
            entries7dAvg.last,
            currentCategory.unit,
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: Text(AppLocalizations.of(context).goToDetailPage),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    MeasurementEntriesScreen.routeName,
                    arguments: currentCategory.id,
                  );
                },
              ),
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
