/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/routines_notifier.dart';
import 'package:wger/screens/routine_edit_screen.dart';
import 'package:wger/widgets/core/datetime_input.dart';
import 'package:wger/widgets/core/form_submit_button.dart';

class RoutineForm extends ConsumerStatefulWidget {
  final Routine _routine;
  final bool useListView;

  const RoutineForm(this._routine, {this.useListView = false});

  @override
  _RoutineFormState createState() => _RoutineFormState();
}

class _RoutineFormState extends ConsumerState<RoutineForm> {
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
    final i18n = AppLocalizations.of(context);
    final isOnline = ref.watch(networkStatusProvider);

    final children = [
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
      DateInputWidget(
        key: const Key('field-start-date'),
        value: startDate,
        labelText: i18n.startDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        onChanged: (picked) {
          widget._routine.start = picked;
          setState(() {
            startDate = picked;
          });
        },
        validator: (value) {
          if (endDate.isBefore(startDate)) {
            return 'End date must be after start date';
          }
          if (endDate.difference(startDate).inDays < Routine.MIN_DURATION * 7) {
            return 'Duration of the routine must be more than ${Routine.MIN_DURATION} weeks';
          }
          if (endDate.difference(startDate).inDays > Routine.MAX_DURATION * 7) {
            return 'Duration of the routine must be less than ${Routine.MAX_DURATION} weeks';
          }
          return null;
        },
      ),
      DateInputWidget(
        key: const Key('field-end-date'),
        value: endDate,
        labelText: i18n.endDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        onChanged: (picked) {
          widget._routine.end = picked;
          setState(() {
            endDate = picked;
          });
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
      // Creating a routine needs the server to assign an integer PK; editing an
      // existing one syncs through PowerSync and works offline.
      FormSubmitButton(
        key: const Key(SUBMIT_BUTTON_KEY_NAME),
        enabled: !(widget._routine.id == null && !isOnline),
        label: AppLocalizations.of(context).save,
        onPressed: () async {
          // Validate and save
          final isValid = _form.currentState!.validate();
          if (!isValid) {
            return;
          }
          _form.currentState!.save();

          final routinesProvider = ref.read(routinesRiverpodProvider.notifier);
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
        },
      ),
    ];
    return Form(
      key: _form,
      child: widget.useListView ? ListView(children: children) : Column(children: children),
    );
  }
}
