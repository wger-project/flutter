/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020, 2025 wger Team
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
import 'package:intl/intl.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/session.dart';
import 'package:wger/widgets/routines/forms/session.dart';

class SessionInfo extends StatefulWidget {
  final WorkoutSession _session;

  const SessionInfo(this._session);

  @override
  State<SessionInfo> createState() => _SessionInfoState();
}

class _SessionInfoState extends State<SessionInfo> {
  bool editMode = false;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              i18n.workoutSession,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            subtitle: Text(
              DateFormat.yMd(
                Localizations.localeOf(context).languageCode,
              ).format(widget._session.date),
            ),
            onTap: () => setState(() => editMode = !editMode),
            trailing: Icon(editMode ? Icons.edit_off : Icons.edit),
            contentPadding: EdgeInsets.zero,
          ),
          if (editMode)
            SessionForm(
              widget._session.routineId!,
              onSaved: () => setState(() => editMode = false),
              session: widget._session,
            )
          else
            Column(
              children: [
                SessionRow(
                  label: i18n.impression,
                  value: widget._session.impressionAsString(context),
                ),
                SessionRow(
                  label: i18n.duration,
                  value: widget._session.durationTxtWithStartEnd(context),
                ),
                SessionRow(
                  label: i18n.notes,
                  value: (widget._session.notes != null && widget._session.notes!.isNotEmpty)
                      ? widget._session.notes!
                      : '-/-',
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class SessionRow extends StatelessWidget {
  const SessionRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
