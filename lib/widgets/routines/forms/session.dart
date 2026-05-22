/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2025 wger Team
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

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/error_dialogs.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/workout_session_notifier.dart';
import 'package:wger/widgets/core/datetime_input.dart';

class SessionForm extends ConsumerStatefulWidget {
  final _logger = Logger('SessionForm');
  final WorkoutSession _session;
  final Function()? _onSaved;

  static const SLIDER_START = -0.5;

  SessionForm(int routineId, {Function()? onSaved, WorkoutSession? session, int? dayId})
    : _onSaved = onSaved,
      _session =
          session ??
          WorkoutSession(
            routineId: routineId,
            dayId: dayId,
            date: clock.now(),
            timeEnd: TimeOfDay.fromDateTime(clock.now()),
            timeStart: null,
          );

  @override
  _SessionFormState createState() => _SessionFormState();
}

class _SessionFormState extends ConsumerState<SessionForm> {
  Widget errorMessage = const SizedBox.shrink();
  final _form = GlobalKey<FormState>();

  final notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    notesController.text = widget._session.notes ?? '';
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = ref.read(workoutSessionProvider.notifier);

    return Form(
      key: _form,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          errorMessage,
          ToggleButtons(
            key: const ValueKey('impression-toggle-buttons'),
            renderBorder: false,
            onPressed: (int index) {
              setState(() {
                widget._session.impression = WorkoutImpression.values[index];
              });
            },
            isSelected: WorkoutImpression.values
                .map((e) => e == widget._session.impression)
                .toList(),
            children: const [
              Icon(Icons.sentiment_very_dissatisfied),
              Icon(Icons.sentiment_neutral),
              Icon(Icons.sentiment_very_satisfied),
            ],
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).notes,
            ),
            maxLines: 3,
            controller: notesController,
            keyboardType: TextInputType.multiline,
            onFieldSubmitted: (_) {},
            onSaved: (newValue) {
              widget._session.notes = newValue!;
            },
          ),
          Row(
            spacing: 10,
            children: [
              Flexible(
                child: TimeInputWidget(
                  key: const ValueKey('time-start'),
                  value: widget._session.timeStart,
                  labelText: AppLocalizations.of(context).timeStart,
                  onCleared: () => widget._session.timeStart = null,
                  onChanged: (time) => widget._session.timeStart = time,
                  validator: (_) {
                    final start = widget._session.timeStart;
                    final end = widget._session.timeEnd;
                    if (start != null && end != null && start.isAfter(end)) {
                      return AppLocalizations.of(context).timeStartAhead;
                    }
                    return null;
                  },
                ),
              ),
              Flexible(
                child: TimeInputWidget(
                  key: const ValueKey('time-end'),
                  value: widget._session.timeEnd,
                  labelText: AppLocalizations.of(context).timeEnd,
                  onCleared: () => widget._session.timeEnd = null,
                  onChanged: (time) => widget._session.timeEnd = time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            key: const ValueKey('save-button'),
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              // Validate and save the current values to the weightEntry
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              // Reset any previous error message
              setState(() {
                errorMessage = const SizedBox.shrink();
              });

              // Save the entry on the server
              try {
                if (widget._session.id == null) {
                  widget._logger.fine('Adding new session');
                  await sessionProvider.addEntry(widget._session);
                } else {
                  widget._logger.fine('Editing existing session with id ${widget._session.id}');
                  await sessionProvider.updateEntry(widget._session);
                }

                setState(() {
                  errorMessage = const SizedBox.shrink();
                });

                if (context.mounted && widget._onSaved != null) {
                  widget._onSaved!();
                }
              } on WgerHttpException catch (error) {
                widget._logger.warning('Could not save session: $error');
                if (context.mounted) {
                  setState(() {
                    errorMessage = FormHttpErrorsWidget(error);
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
