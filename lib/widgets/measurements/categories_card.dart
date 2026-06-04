import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
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
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                currentCategory.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // Group
            if (currentCategory.groupDetail != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Chip(
                  avatar: const Icon(Icons.link, size: 14),
                  label: Text(
                    currentCategory.groupDetail!.name,
                    style: const TextStyle(fontSize: 11),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),
            // Dynamic
            if (currentCategory.isDynamic)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Chip(
                  avatar: const Icon(Icons.auto_graph, size: 14, color: Colors.blue),
                  label: const Text(
                    'Auto-calculated',
                    style: TextStyle(fontSize: 11, color: Colors.blue),
                  ),
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
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
            if (entries7dAvg.isNotEmpty)
              MeasurementOverallChangeWidget(
                entries7dAvg.first,
                entries7dAvg.last,
                currentCategory.unit,
              ),
            const Divider(),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
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
                        // hide add-entry button for dynamic categories
                        if (!currentCategory.isDynamic)
                          IconButton(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                FormScreen.routeName,
                                arguments: FormScreenArguments(
                                  AppLocalizations.of(context).newEntry,
                                  MeasurementEntryForm(
                                    categoryId: currentCategory.id!,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
