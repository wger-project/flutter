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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:wger/exceptions/http_exception.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/providers/routines.dart';
import 'package:wger/widgets/routines/gym_mode/navigation.dart';

class SessionPage extends StatefulWidget {
  final Routine _routine;
  late WorkoutSession _session;
  final PageController _controller;
  final TimeOfDay _start;
  final Map<Exercise, int> _exercisePages;

  SessionPage(
    this._routine,
    this._controller,
    this._start,
    this._exercisePages,
  ) {
    _session = _routine.sessions.map((sessionApi) => sessionApi.session).firstWhere(
          (session) => session.date.isSameDayAs(DateTime.now()),
          orElse: () => WorkoutSession(
            routineId: _routine.id!,
            impression: DEFAULT_IMPRESSION,
            date: DateTime.now(),
            timeEnd: TimeOfDay.now(),
            timeStart: _start,
          ),
        );
  }

  @override
  _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final _form = GlobalKey<FormState>();
  final impressionController = TextEditingController();
  final notesController = TextEditingController();
  final timeStartController = TextEditingController();
  final timeEndController = TextEditingController();

  // final _session = WorkoutSession.now();

  /// Selected impression: bad, neutral, good
  var selectedImpression = [false, true, false];

  @override
  void initState() {
    super.initState();

    timeStartController.text = timeToString(widget._session.timeStart)!;
    timeEndController.text = timeToString(widget._session.timeEnd)!;
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

    return Column(
      children: [
        NavigationHeader(
          AppLocalizations.of(context).workoutSession,
          widget._controller,
          exercisePages: widget._exercisePages,
        ),
        const Divider(),
        Expanded(child: Container()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _form,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ToggleButtons(
                  renderBorder: false,
                  onPressed: (int index) {
                    setState(() {
                      for (int buttonIndex = 0;
                          buttonIndex < selectedImpression.length;
                          buttonIndex++) {
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
                  children: [
                    Flexible(
                      child: TextFormField(
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
                          widget._session.timeStart = stringToTime(newValue);
                        },
                        validator: (_) {
                          final TimeOfDay startTime = stringToTime(timeStartController.text);
                          final TimeOfDay endTime = stringToTime(timeEndController.text);
                          if (startTime.isAfter(endTime)) {
                            return AppLocalizations.of(context).timeStartAhead;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: TextFormField(
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
                          widget._session.timeEnd = stringToTime(newValue);
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  child: Text(AppLocalizations.of(context).save),
                  onPressed: () async {
                    // Validate and save the current values to the weightEntry
                    final isValid = _form.currentState!.validate();
                    if (!isValid) {
                      return;
                    }
                    _form.currentState!.save();

                    // Save the entry on the server
                    try {
                      if (widget._session.id == null) {
                        await routinesProvider.addSession(widget._session, widget._routine.id!);
                      } else {
                        await routinesProvider.editSession(widget._session);
                      }

                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    } on WgerHttpException catch (error) {
                      if (mounted) {
                        showHttpExceptionErrorDialog(error, context);
                      }
                    } catch (error) {
                      if (mounted) {
                        showErrorDialog(error, context);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        NavigationFooter(widget._controller, 1, showNext: false),
      ],
    );
  }
}
