import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/routine_screen.dart';

class RoutineForm extends StatefulWidget {
  final Routine _routine;

  const RoutineForm(this._routine);

  @override
  State<RoutineForm> createState() => _RoutineFormState();
}

class _RoutineFormState extends State<RoutineForm> {
  final _form = GlobalKey<FormState>();

  late bool fitInWeek;
  late DateTime startDate;
  late DateTime endDate;
  final workoutNameController = TextEditingController();
  final workoutDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fitInWeek = widget._routine.fitInWeek;
    workoutNameController.text = widget._routine.name;
    workoutDescriptionController.text = widget._routine.description;
    startDate = widget._routine.start;
    endDate = widget._routine.end;
  }

  @override
  void dispose() {
    workoutNameController.dispose();
    workoutDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: [
          TextFormField(
            key: const Key('field-name'),
            decoration: InputDecoration(labelText: AppLocalizations.of(context).name),
            controller: workoutNameController,
            validator: (value) {
              if (value!.isEmpty ||
                  value.length < MIN_LENGTH_NAME ||
                  value.length > MAX_LENGTH_NAME) {
                return AppLocalizations.of(context).enterCharacters(
                  MIN_LENGTH_NAME,
                  MAX_LENGTH_NAME,
                );
              }
              return null;
            },
            onSaved: (newValue) {
              widget._routine.name = newValue!;
            },
          ),
          TextFormField(
            key: const Key('field-description'),
            decoration: InputDecoration(labelText: AppLocalizations.of(context).description),
            minLines: 3,
            maxLines: 10,
            controller: workoutDescriptionController,
            validator: (value) {
              if (value!.length > MAX_LENGTH_DESCRIPTION) {
                return AppLocalizations.of(context).enterCharacters(
                  MIN_LENGTH_DESCRIPTION,
                  MAX_LENGTH_DESCRIPTION,
                );
              }
              return null;
            },
            onSaved: (newValue) {
              widget._routine.description = newValue!;
            },
          ),
          TextFormField(
            key: const Key('field-start-date'),
            // Stop keyboard from appearing
            readOnly: true,
            validator: (value) {
              if (endDate.isBefore(startDate)) {
                return 'End date must be after start date';
              }
              if (endDate.difference(startDate).inDays < MIN_DURATION * 7) {
                return 'Duration of the routine must be more than $MIN_DURATION weeks';
              }
              if (endDate.difference(startDate).inDays > MAX_DURATION * 7) {
                return 'Duration of the routine must be less than $MAX_DURATION weeks';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Start date',
              suffixIcon: Icon(
                Icons.calendar_today,
                key: Key('calendarIcon'),
              ),
            ),
            enableInteractiveSelection: false,
            controller: TextEditingController(
              text: DateFormat.yMd(
                Localizations.localeOf(context).languageCode,
              ).format(startDate),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: startDate,
                firstDate: DateTime(DateTime.now().year - 10),
                lastDate: DateTime.now(),
              );

              if (picked == null) {
                return;
              }

              widget._routine.start = picked;
              if (mounted) {
                setState(() {
                  startDate = picked;
                });
              }
            },
          ),
          TextFormField(
            key: const Key('field-end-date'),
            // Stop keyboard from appearing
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'End date',
              suffixIcon: Icon(
                Icons.calendar_today,
                key: Key('calendarIcon'),
              ),
            ),
            enableInteractiveSelection: false,
            controller: TextEditingController(
              text: DateFormat.yMd(
                Localizations.localeOf(context).languageCode,
              ).format(endDate),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: endDate,
                firstDate: DateTime(DateTime.now().year - 10),
                lastDate: DateTime.now(),
              );

              if (picked == null) {
                return;
              }

              widget._routine.end = picked;
              if (mounted) {
                setState(() {
                  endDate = picked;
                });
              }
            },
          ),
          SwitchListTile(
            title: const Text('Fit in week'),
            value: widget._routine.fitInWeek,
            onChanged: (bool? value) {
              if (value == null) {
                return;
              }

              widget._routine.fitInWeek = value;
              if (mounted) {
                setState(() {
                  fitInWeek = value;
                });
              }
            },
          ),
          ElevatedButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              // Validate and save
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              // Save to DB
              if (widget._routine.id != null) {
                await Provider.of<RoutinesProvider>(context, listen: false)
                    .editRoutine(widget._routine);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                final Routine newPlan = await Provider.of<RoutinesProvider>(
                  context,
                  listen: false,
                ).addRoutine(widget._routine);
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(
                    RoutineScreen.routeName,
                    arguments: newPlan,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
