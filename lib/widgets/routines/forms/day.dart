import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';

class ReorderableDaysList extends StatefulWidget {
  int routineId;
  List<Day> days;

  ReorderableDaysList(this.days, this.routineId, {super.key});

  @override
  State<ReorderableDaysList> createState() => _ReorderableDaysListState();
}

class _ReorderableDaysListState extends State<ReorderableDaysList> {
  int? selectedDayId;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.days.length + 1,
      itemBuilder: (context, index) {
        // "add day" button always at the end
        if (index == widget.days.length) {
          return ListTile(
            key: const ValueKey('add-day'),
            // tileColor: Theme.of(context).highlightColor,
            leading: const Icon(Icons.add),
            title: Text(
              AppLocalizations.of(context).newDay,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () {
              final newDay = Day.empty();
              newDay.routineId = widget.routineId;
              Provider.of<RoutinesProvider>(context, listen: false).addDay(newDay, refresh: true);
            },
          );
        }

        final day = widget.days[index];

        return ListTile(
          tileColor: day.id == selectedDayId ? Theme.of(context).highlightColor : null,
          key: ValueKey(day),
          title: Text(day.isRest ? 'REST DAY!' : day.name),
          leading: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
          trailing: IconButton(
            onPressed: () {
              setState(() {
                selectedDayId = day.id;
              });
            },
            icon: const Icon(Icons.edit),
          ),
        );
      },
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Day item = widget.days.removeAt(oldIndex);
          widget.days.insert(newIndex, item);

          for (int i = 0; i < widget.days.length; i++) {
            widget.days[i].order = i + 1;
          }
        });

        Provider.of<RoutinesProvider>(context, listen: false).editDays(widget.days);
      },
    );
  }
}

class DayFormWidget extends StatefulWidget {
  final Routine routine;
  final dayController = TextEditingController();
  late final Day _day;

  DayFormWidget(this.routine, [Day? day]) {
    _day = day ?? Day();
    _day.routineId = routine.id!;
    if (_day.id != null) {
      dayController.text = day!.description;
    }
  }

  @override
  _DayFormWidgetState createState() => _DayFormWidgetState();
}

class _DayFormWidgetState extends State<DayFormWidget> {
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: ListView(
        children: [
          TextFormField(
            key: const Key('field-description'),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).description,
              helperText: AppLocalizations.of(context).dayDescriptionHelp,
              helperMaxLines: 3,
            ),
            controller: widget.dayController,
            onSaved: (value) {
              widget._day.description = value!;
            },
            validator: (value) {
              const minLength = 1;
              const maxLength = 100;
              if (value!.isEmpty || value.length < minLength || value.length > maxLength) {
                return AppLocalizations.of(context).enterCharacters(minLength, maxLength);
              }

              return null;
            },
          ),
          ElevatedButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              if (!_form.currentState!.validate()) {
                return;
              }
              _form.currentState!.save();

              try {
                if (widget._day.id == null) {
                  // Provider.of<RoutinesProvider>(context, listen: false).addDay(
                  //   widget._day,
                  //   widget.routine,
                  // );
                } else {
                  Provider.of<RoutinesProvider>(context, listen: false).editDay(
                    widget._day,
                  );
                }

                widget.dayController.clear();
                Navigator.of(context).pop();
              } catch (error) {
                await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('An error occurred!'),
                    content: const Text('Something went wrong.'),
                    actions: [
                      TextButton(
                        child: const Text('Okay'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
