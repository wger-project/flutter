import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/screens/routine_edit_screen.dart';
import 'package:wger/widgets/core/progress_indicator.dart';

/// A form widget for creating and editing workout routines.
/// Handles validation and user input for routine details, including start and end dates.
class RoutineForm extends StatefulWidget {
  final Routine _routine;
  final bool useListView;

  const RoutineForm(this._routine, {this.useListView = false});

  @override
  State<RoutineForm> createState() => _RoutineFormState();
}

class _RoutineFormState extends State<RoutineForm> {
  final _form = GlobalKey<FormState>();
  Widget errorMessage = const SizedBox.shrink();

  bool isSaving = false;
  late bool fitInWeek;
  late DateTime startDate;
  DateTime? endDate;
  final workoutNameController = TextEditingController();
  final workoutDescriptionController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fitInWeek = widget._routine.fitInWeek;
    workoutNameController.text = widget._routine.name;
    workoutDescriptionController.text = widget._routine.description;
    startDate = widget._routine.start;
    endDate = widget._routine.end == widget._routine.start ? null : widget._routine.end;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = Localizations.localeOf(context).languageCode;
      startDateController.text = DateFormat.yMd(locale).format(startDate);
      endDateController.text = endDate != null ? DateFormat.yMd(locale).format(endDate!) : '';
    });
  }

  @override
  void dispose() {
    workoutNameController.dispose();
    workoutDescriptionController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    final children = [
      errorMessage,
      TextFormField(
        key: const Key('field-name'),
        decoration: InputDecoration(labelText: i18n.name),
        controller: workoutNameController,
        validator: (value) {
          if (value!.isEmpty ||
              value.length < Routine.MIN_LENGTH_NAME ||
              value.length > Routine.MAX_LENGTH_NAME) {
            return i18n.enterCharacters(
              Routine.MIN_LENGTH_NAME.toString(),
              Routine.MAX_LENGTH_NAME.toString(),
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
        decoration: InputDecoration(labelText: i18n.description),
        minLines: 3,
        maxLines: 10,
        controller: workoutDescriptionController,
        validator: (value) {
          if (value!.length > Routine.MAX_LENGTH_DESCRIPTION) {
            return i18n.enterCharacters(
              Routine.MIN_LENGTH_DESCRIPTION.toString(),
              Routine.MAX_LENGTH_DESCRIPTION.toString(),
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
        readOnly: true,
        validator: (value) {
          if (endDate != null) {
            if (endDate!.isBefore(startDate)) {
              return 'End date must be after start date';
            }
            if (endDate!.difference(startDate).inDays < Routine.MIN_DURATION * 7) {
              return 'Duration of the routine must be more than  {Routine.MIN_DURATION} weeks';
            }
            if (endDate!.difference(startDate).inDays > Routine.MAX_DURATION * 7) {
              return 'Duration of the routine must be less than  {Routine.MAX_DURATION} weeks';
            }
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
        controller: startDateController,
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
              final locale = Localizations.localeOf(context).languageCode;
              startDateController.text = DateFormat.yMd(locale).format(startDate);
            });
          }
        },
      ),
      TextFormField(
        key: const Key('field-end-date'),
        readOnly: true,
        /// Opens a date picker for selecting the routine's end date.
        /// Ensures the end date is always after the start date and allows selection up to 10 years in the future.
        /// The initial date shown is the current end date if valid, otherwise the minimum allowed end date.
        decoration: const InputDecoration(
          labelText: 'End date',
          suffixIcon: Icon(
            Icons.calendar_today,
            key: Key('calendarIcon'),
          ),
        ),
        enableInteractiveSelection: false,
        controller: endDateController,
        onTap: () async {
          final now = DateTime.now();
          final firstEndDate = startDate.add(const Duration(days: 1));
          DateTime initial = firstEndDate;
          if (endDate != null && endDate!.isAfter(firstEndDate)) {
            initial = endDate!;
          }
          final picked = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: firstEndDate,
            lastDate: now.add(const Duration(days: 365 * 10)),
          );

          if (picked == null) {
            return;
          }

          widget._routine.end = picked;
          if (mounted) {
            setState(() {
              endDate = picked;
              final locale = Localizations.localeOf(context).languageCode;
              endDateController.text = DateFormat.yMd(locale).format(endDate!);
            });
          }
        },
      ),
      const SizedBox(height: 5),
      SwitchListTile(
        title: Text(i18n.fitInWeek),
        subtitle: Text(i18n.fitInWeekHelp),
        isThreeLine: true,
        value: widget._routine.fitInWeek,
        contentPadding: const EdgeInsets.all(4),
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
      const SizedBox(height: 5),
      ElevatedButton(
        key: const Key(SUBMIT_BUTTON_KEY_NAME),
        onPressed: isSaving
            ? null
            : () async {
                // Validate and save
                final isValid = _form.currentState!.validate();
                if (!isValid) {
                  return;
                }
                _form.currentState!.save();
                setState(() {
                  isSaving = true;
                });

                // Save to DB
                try {
                  final routinesProvider = context.read<RoutinesProvider>();

                  if (widget._routine.id != null) {
                    await routinesProvider.editRoutine(widget._routine);
                  } else {
                    final routine = await routinesProvider.addRoutine(widget._routine);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(
                        RoutineEditScreen.routeName,
                        arguments: routine.id,
                      );
                    }
                  }
                  setState(() {
                    errorMessage = const SizedBox.shrink();
                  });
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
        child: isSaving ? const FormProgressIndicator() : Text(AppLocalizations.of(context).save),
      ),
    ];
    return Form(
      key: _form,
      child: widget.useListView ? ListView(children: children) : Column(children: children),
    );
  }
}
