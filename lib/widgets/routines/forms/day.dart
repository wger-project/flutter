import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/core/progress_indicator.dart';
import 'package:wger/widgets/routines/forms/slot.dart';

class ReorderableDaysList extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<ReorderableDaysList> createState() => _ReorderableDaysListState();
}

class _ReorderableDaysListState extends ConsumerState<ReorderableDaysList> {
  Widget errorMessage = const SizedBox.shrink();

  void _showDeleteConfirmationDialog(BuildContext context, Day day) {
    final i18n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(i18n.delete),
          content: Text(i18n.confirmDelete(day.isRest ? i18n.restDay : day.name)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                widget.days.remove(day);
                await ref.read(routinesRiverpodProvider.notifier).deleteDay(day.id!, day.routineId);
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
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final provider = ref.read(routinesRiverpodProvider.notifier);

    return Column(
      children: [
        errorMessage,
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
                title: Text(day.isRest ? i18n.restDay : day.name),
                leading: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                subtitle: Text(
                  day.description,
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: ValueKey('edit-day-${day.id}'),
                      onPressed: () => widget.onDaySelected(day.id!),
                      icon: isDaySelected ? const Icon(Icons.edit_off) : const Icon(Icons.edit),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmationDialog(context, day),
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

            try {
              provider.editDays(widget.days);
              setState(() {
                errorMessage = const SizedBox.shrink();
              });
            } on WgerHttpException catch (error) {
              if (context.mounted) {
                setState(() {
                  errorMessage = FormHttpErrorsWidget(error);
                });
              }
            }
          },
        ),
        Card(
          child: ListTile(
            key: const ValueKey('add-day'),
            // tileColor: Theme.of(context).focusColor,
            leading: const Icon(Icons.add),
            title: Text(
              AppLocalizations.of(context).newDay,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: () async {
              final day = Day(
                routineId: widget.routineId,
                name: '${i18n.newDay} ${widget.days.length + 1}',
                order: widget.days.length + 1,
              );
              final newDay = await provider.addDay(day);

              widget.onDaySelected(newDay.id!);
            },
          ),
        ),
      ],
    );
  }
}

class DayFormWidget extends ConsumerStatefulWidget {
  late final Day day;

  DayFormWidget({required Day day, super.key}) {
    this.day = day.copyWith();
  }

  @override
  _DayFormWidgetState createState() => _DayFormWidgetState();
}

class _DayFormWidgetState extends ConsumerState<DayFormWidget> {
  Widget errorMessage = const SizedBox.shrink();

  final descriptionController = TextEditingController();
  final nameController = TextEditingController();
  bool isSaving = false;

  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
    final i18n = AppLocalizations.of(context);

    return Form(
      key: _form,
      child: Column(
        children: [
          errorMessage,
          Text(
            widget.day.isRest ? i18n.restDay : widget.day.name,
            style: Theme.of(context).textTheme.titleLarge,
            key: ValueKey('day-title-${widget.day.id!}'),
          ),
          SwitchListTile(
            key: const Key('field-is-rest-day'),
            title: Text(i18n.isRestDay),
            subtitle: Text(i18n.isRestDayHelp),
            value: widget.day.isRest,
            contentPadding: const EdgeInsets.all(4),
            onChanged: (value) {
              setState(() {
                widget.day.isRest = value;
                widget.day.type = DayType.custom;
                widget.day.needLogsToAdvance = false;
                nameController.clear();
                descriptionController.clear();
              });
              widget.day.isRest = value;
            },
          ),
          TextFormField(
            enabled: !widget.day.isRest,
            key: const Key('field-name'),
            decoration: InputDecoration(labelText: i18n.name),
            controller: nameController,
            onSaved: (value) {
              widget.day.name = value!;
            },
            validator: (value) {
              if (widget.day.isRest) {
                return null;
              }

              if (value!.isEmpty ||
                  value.length < Day.MIN_LENGTH_NAME ||
                  value.length > Day.MAX_LENGTH_NAME) {
                return i18n.enterCharacters(
                  Day.MIN_LENGTH_NAME.toString(),
                  Day.MAX_LENGTH_NAME.toString(),
                );
              }

              return null;
            },
          ),

          TextFormField(
            key: const Key('field-description'),
            enabled: !widget.day.isRest,
            decoration: InputDecoration(labelText: i18n.description),
            controller: descriptionController,
            onSaved: (value) {
              widget.day.description = value!;
            },
            minLines: 2,
            maxLines: 10,
            validator: (value) {
              if (widget.day.isRest) {
                return null;
              }

              if (value != null && value.length > Day.MAX_LENGTH_DESCRIPTION) {
                return i18n.enterCharacters('0', Day.MAX_LENGTH_DESCRIPTION.toString());
              }

              return null;
            },
          ),
          DropdownButtonFormField<DayType>(
            key: const Key('field-day-type'),
            initialValue: widget.day.type,
            decoration: const InputDecoration(labelText: 'Typ'),
            items: DayType.values.map((type) {
              return DropdownMenuItem(
                key: Key('day-type-option-${type.name}'),
                value: type,
                child: Text('${type.name.toUpperCase()} - ${type.i18Label(i18n)}'),
              );
            }).toList(),
            onChanged: widget.day.isRest
                ? null
                : (value) {
                    setState(() {
                      widget.day.type = value!;
                    });
                  },
          ),
          SwitchListTile(
            key: const Key('field-need-logs-to-advance'),
            title: Text(i18n.needsLogsToAdvance),
            subtitle: Text(i18n.needsLogsToAdvanceHelp),
            value: widget.day.needLogsToAdvance,
            contentPadding: const EdgeInsets.all(4),
            onChanged: widget.day.isRest
                ? null
                : (value) {
                    setState(() {
                      widget.day.needLogsToAdvance = value;
                    });
                  },
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            onPressed: isSaving
                ? null
                : () async {
                    if (!_form.currentState!.validate()) {
                      return;
                    }
                    _form.currentState!.save();
                    setState(() => isSaving = true);

                    try {
                      await ref.read(routinesRiverpodProvider.notifier).editDay(widget.day);
                      if (context.mounted) {
                        setState(() {
                          errorMessage = const SizedBox.shrink();
                        });
                      }
                    } on WgerHttpException catch (error) {
                      if (context.mounted) {
                        setState(() {
                          errorMessage = FormHttpErrorsWidget(error);
                        });
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          isSaving = false;
                        });
                      }
                    }
                  },
            child: isSaving
                ? const FormProgressIndicator()
                : Text(AppLocalizations.of(context).save),
          ),
          const SizedBox(height: 5),
          ReorderableSlotList(widget.day.slots, widget.day),
        ],
      ),
    );
  }
}
