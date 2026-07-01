/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'package:wger/features/routines/models/session.dart';
import 'package:wger/features/routines/providers/workout_session_notifier.dart';
import 'package:wger/features/routines/validators.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/widgets/core/datetime_input.dart';
import 'package:wger/widgets/core/form_submit_button.dart';

class SessionForm extends ConsumerStatefulWidget {
  final _logger = Logger('SessionForm');
  final int _routineId;
  final int? _dayId;

  /// The session to edit, or null to create a new one.
  final WorkoutSession? _session;
  final Function()? _onSaved;

  SessionForm(this._routineId, {Function()? onSaved, WorkoutSession? session, int? dayId})
    : _onSaved = onSaved,
      _session = session,
      _dayId = dayId;

  @override
  _SessionFormState createState() => _SessionFormState();
}

class _SessionFormState extends ConsumerState<SessionForm> {
  final _form = GlobalKey<FormState>();

  final notesController = TextEditingController();

  /// Editable copy. Seeded once and owned by the form, so parent rebuilds
  /// (e.g. stream re-emissions) don't clobber the user's in-progress edits.
  late WorkoutSession _draft;

  @override
  void initState() {
    super.initState();
    _draft =
        widget._session ??
        WorkoutSession(routineId: widget._routineId, dayId: widget._dayId, date: clock.now());
    notesController.text = _draft.notes ?? '';
  }

  @override
  void didUpdateWidget(SessionForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Adopt a new server identity (e.g. a session created lazily while logging
    // arrives only after the form first built) without discarding edits when
    // the same session is merely re-emitted by the stream.
    if (widget._session != null && widget._session!.id != oldWidget._session?.id) {
      _draft = widget._session!;
      notesController.text = _draft.notes ?? '';
    }
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
          ToggleButtons(
            key: const ValueKey('impression-toggle-buttons'),
            renderBorder: false,
            onPressed: (int index) {
              setState(() {
                _draft = _draft.copyWith(impression: WorkoutImpression.values[index]);
              });
            },
            isSelected: WorkoutImpression.values.map((e) => e == _draft.impression).toList(),
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
            maxLength: WorkoutSession.maxNotesChars,
            controller: notesController,
            keyboardType: TextInputType.multiline,
            onFieldSubmitted: (_) {},
            onSaved: (newValue) {
              _draft = _draft.copyWith(notes: newValue);
            },
            validator: (value) {
              if (value != null && value.length > WorkoutSession.maxNotesChars) {
                return AppLocalizations.of(
                  context,
                ).enterMaxCharacters(WorkoutSession.maxNotesChars.toString());
              }
              return null;
            },
          ),
          Row(
            spacing: 10,
            children: [
              Flexible(
                child: TimeInputWidget(
                  key: const ValueKey('time-start'),
                  value: _draft.timeStart,
                  labelText: AppLocalizations.of(context).timeStart,
                  onCleared: () => _draft = _draft.copyWith(timeStart: null),
                  onChanged: (time) => _draft = _draft.copyWith(timeStart: time),
                ),
              ),
              Flexible(
                child: TimeInputWidget(
                  key: const ValueKey('time-end'),
                  value: _draft.timeEnd,
                  labelText: AppLocalizations.of(context).timeEnd,
                  onCleared: () => _draft = _draft.copyWith(timeEnd: null),
                  onChanged: (time) => _draft = _draft.copyWith(timeEnd: time),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          FormSubmitButton(
            key: const ValueKey('save-button'),
            label: AppLocalizations.of(context).save,
            onPressed: () async {
              if (!_form.currentState!.validate()) {
                return;
              }
              _form.currentState!.save();

              final i18n = AppLocalizations.of(context);
              final error = validateWorkoutSessionTimes(
                timeStart: _draft.timeStart,
                timeEnd: _draft.timeEnd,
                i18n: i18n,
              );
              if (error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                return;
              }

              // A WgerHttpException is surfaced inline by FormSubmitButton.
              if (_draft.id == null) {
                widget._logger.fine('Adding new session');
                await sessionProvider.addEntry(_draft);
              } else {
                widget._logger.fine('Editing existing session with id ${_draft.id}');
                await sessionProvider.updateEntry(_draft);
              }

              if (context.mounted && widget._onSaved != null) {
                widget._onSaved!();
              }
            },
          ),
        ],
      ),
    );
  }
}
