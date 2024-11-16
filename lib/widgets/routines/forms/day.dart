import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/forms/slot.dart';

class ReorderableDaysList extends StatefulWidget {
  final int routineId;
  final List<Day> days;
  final int? selectedDayId;
  final ValueChanged<int> onDaySelected;

  const ReorderableDaysList({
    super.key,
    required this.routineId,
    required this.days,
    required this.selectedDayId,
    required this.onDaySelected,
  });

  void _showDeleteConfirmationDialog(BuildContext context, Day day) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this day?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                days.remove(day);
                await Provider.of<RoutinesProvider>(context, listen: false).deleteDay(day.id!);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  State<ReorderableDaysList> createState() => _ReorderableDaysListState();
}

class _ReorderableDaysListState extends State<ReorderableDaysList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReorderableListView.builder(
          buildDefaultDragHandles: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.days.length,
          itemBuilder: (context, index) {
            final day = widget.days[index];
            final isDaySelected = day.id == widget.selectedDayId;

            return Card(
              key: ValueKey(day),
              child: ListTile(
                //selected: day.id == widget.selectedDayId,
                tileColor: isDaySelected ? Theme.of(context).highlightColor : null,
                key: ValueKey(day),
                title: Text(day.isRest ? 'REST DAY!' : day.name),
                leading: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                subtitle: Text(
                  day.isRest ? '' : day.description,
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        widget.onDaySelected(day.id!);
                      },
                      icon: isDaySelected ? const Icon(Icons.edit_off) : const Icon(Icons.edit),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        widget._showDeleteConfirmationDialog(
                          context,
                          day,
                        ); // Call the dialog function
                      },
                    ),
                  ],
                ),
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
        ),
        ListTile(
          key: const ValueKey('add-day'),
          // tileColor: Theme.of(context).highlightColor,
          leading: const Icon(Icons.add),
          title: Text(
            AppLocalizations.of(context).newDay,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          onTap: () async {
            final newDay = Day.empty();
            newDay.routineId = widget.routineId;
            final result = await Provider.of<RoutinesProvider>(context, listen: false)
                .addDay(newDay, refresh: true);
            widget.onDaySelected(result.id!);
          },
        ),
      ],
    );
  }
}

class DayFormWidget extends StatefulWidget {
  final int routineId;
  late final Day day;

  DayFormWidget({required this.routineId, required this.day, super.key}) {
    day.routineId = routineId;
  }

  @override
  _DayFormWidgetState createState() => _DayFormWidgetState();
}

class _DayFormWidgetState extends State<DayFormWidget> {
  final descriptionController = TextEditingController();
  final nameController = TextEditingController();
  late bool isRestDay;

  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isRestDay = widget.day.isRest;
    descriptionController.text = widget.day.description;
    nameController.text = widget.day.name;
  }

  @override
  void dispose() {
    descriptionController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: [
          Text(
            widget.day.isRest ? 'REST DAY' : widget.day.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          TextFormField(
            key: const Key('field-name'),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).name,
            ),
            controller: nameController,
            onSaved: (value) {
              widget.day.name = value!;
            },
            validator: (value) {
              if (value!.isEmpty ||
                  value.length < Day.MIN_LENGTH_NAME ||
                  value.length > Day.MAX_LENGTH_NAME) {
                return AppLocalizations.of(context).enterCharacters(
                  Day.MIN_LENGTH_NAME,
                  Day.MAX_LENGTH_NAME,
                );
              }

              return null;
            },
          ),
          SwitchListTile(
            title: const Text('is rest day'),
            value: isRestDay,
            contentPadding: const EdgeInsets.all(4),
            onChanged: (value) {
              setState(() {
                isRestDay = value;
              });
              widget.day.isRest = value;
            },
          ),
          TextFormField(
            key: const Key('field-description'),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).description,
              helperText: AppLocalizations.of(context).dayDescriptionHelp,
              helperMaxLines: 3,
            ),
            controller: descriptionController,
            onSaved: (value) {
              widget.day.description = value!;
            },
            minLines: 2,
            maxLines: 10,
            validator: (value) {
              if (value != null && value.length > Day.MAX_LENGTH_DESCRIPTION) {
                return AppLocalizations.of(context).enterCharacters(0, Day.MAX_LENGTH_DESCRIPTION);
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
                Provider.of<RoutinesProvider>(context, listen: false).editDay(
                  widget.day,
                );
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
          ReorderableSlotList(widget.day.slots, widget.day.id!),
        ],
      ),
    );
  }
}
