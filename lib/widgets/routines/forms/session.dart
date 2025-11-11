/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/routines.dart';

class SessionForm extends StatefulWidget {
  final _logger = Logger('SessionForm');
  final WorkoutSession _session;
  final int? _routineId;
  final Function()? _onSaved;

  static const SLIDER_START = -0.5;

  SessionForm(this._routineId, {Function()? onSaved, WorkoutSession? session, int? dayId})
    : _onSaved = onSaved,
      _session =
          session ??
          WorkoutSession(
            routineId: _routineId,
            dayId: dayId,
            impression: DEFAULT_IMPRESSION,
            date: clock.now(),
            timeEnd: TimeOfDay.fromDateTime(clock.now()),
            timeStart: null,
          );

  @override
  _SessionFormState createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  Widget errorMessage = const SizedBox.shrink();
  final _form = GlobalKey<FormState>();

  final impressionController = TextEditingController();
  final notesController = TextEditingController();
  final timeStartController = TextEditingController();
  final timeEndController = TextEditingController();

  /// Selected impression: bad,  neutral, good
  var selectedImpression = [false, false, false];

  @override
  void initState() {
    super.initState();

    timeStartController.text = widget._session.timeStart == null
        ? ''
        : timeToString(widget._session.timeStart)!;
    timeEndController.text = widget._session.timeEnd == null
        ? ''
        : timeToString(widget._session.timeEnd)!;
    notesController.text = widget._session.notes;

    selectedImpression[widget._session.impression - 1] = true;
  }

  @override
  void dispose() {
    impressionController.dispose();
    notesController.dispose();
    timeStartController.dispose();
    timeEndController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routinesProvider = context.read<RoutinesProvider>();

    return Form(
      key: _form,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          errorMessage,
          ToggleButtons(
            renderBorder: false,
            onPressed: (int index) {
              setState(() {
                for (int buttonIndex = 0; buttonIndex < selectedImpression.length; buttonIndex++) {
                  widget._session.impression = index + 1;

                  if (buttonIndex == index) {
                    selectedImpression[buttonIndex] = true;
                  } else {
                    selectedImpression[buttonIndex] = false;
                  }
                }
              });
            },
            isSelected: selectedImpression,
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
                child: TextFormField(
                  key: const ValueKey('time-start'),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).timeStart,
                    errorMaxLines: 2,
                  ),
                  controller: timeStartController,
                  onFieldSubmitted: (_) {},
                  onTap: () async {
                    // Stop keyboard from appearing
                    FocusScope.of(context).requestFocus(FocusNode());

                    // Open time picker
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: widget._session.timeStart ?? TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      timeStartController.text = timeToString(pickedTime)!;
                      widget._session.timeStart = pickedTime;
                    }
                  },
                  onSaved: (newValue) {
                    if (newValue != null && newValue.isNotEmpty) {
                      widget._session.timeStart = stringToTime(newValue);
                    }
                  },
                  validator: (_) {
                    if (timeStartController.text.isEmpty && timeEndController.text.isEmpty) {
                      return null;
                    }

                    if (timeStartController.text.isNotEmpty && timeEndController.text.isNotEmpty) {
                      final TimeOfDay startTime = stringToTime(timeStartController.text);
                      final TimeOfDay endTime = stringToTime(timeEndController.text);
                      if (startTime.isAfter(endTime)) {
                        return AppLocalizations.of(context).timeStartAhead;
                      }
                    }

                    return null;
                  },
                ),
              ),
              Flexible(
                child: TextFormField(
                  key: const ValueKey('time-end'),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).timeEnd,
                  ),
                  controller: timeEndController,
                  onFieldSubmitted: (_) {},
                  onTap: () async {
                    // Stop keyboard from appearing
                    FocusScope.of(context).requestFocus(FocusNode());

                    // Open time picker
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: widget._session.timeEnd ?? TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      timeEndController.text = timeToString(pickedTime)!;
                      widget._session.timeEnd = pickedTime;
                    }
                  },
                  onSaved: (newValue) {
                    if (newValue != null && newValue.isNotEmpty) {
                      widget._session.timeEnd = stringToTime(newValue);
                    }
                  },
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
                  await routinesProvider.addSession(widget._session, widget._routineId);
                } else {
                  widget._logger.fine('Editing existing session with id ${widget._session.id}');
                  await routinesProvider.editSession(widget._session);
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
