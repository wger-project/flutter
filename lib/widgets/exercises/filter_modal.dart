import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/exercises.dart';

class ExerciseFilterModalBody extends StatefulWidget {
  const ExerciseFilterModalBody({
    Key? key,
  }) : super(key: key);

  @override
  _ExerciseFilterModalBodyState createState() => _ExerciseFilterModalBodyState();
}

class _ExerciseFilterModalBodyState extends State<ExerciseFilterModalBody> {
  late Filters filters;

  @override
  void initState() {
    super.initState();
    filters = Provider.of<ExercisesProvider>(context, listen: false).filters!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: ExpansionPanelList(
          dividerColor: Colors.transparent,
          expansionCallback: (panelIndex, isExpanded) {
            setState(() {
              filters.filterCategories[panelIndex].isExpanded = !isExpanded;
            });
          },
          elevation: 0,
          children: filters.filterCategories.map((filterCategory) {
            return ExpansionPanel(
              backgroundColor: Colors.transparent,
              isExpanded: filterCategory.isExpanded,
              headerBuilder: (context, isExpanded) {
                return Container(
                  child: Text(
                    filterCategory.title,
                    style: theme.textTheme.headline5,
                  ),
                );
              },
              body: Column(
                children: filterCategory.items.entries.map(
                  (currentEntry) {
                    return CheckboxListTile(
                      title: Text(currentEntry.key.name),
                      value: currentEntry.value,
                      onChanged: (_) {
                        setState(() {
                          filterCategory.items.update(currentEntry.key, (value) => !value);
                          Provider.of<ExercisesProvider>(context, listen: false)
                              .setFilters(filters);
                        });
                      },
                    );
                  },
                ).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
