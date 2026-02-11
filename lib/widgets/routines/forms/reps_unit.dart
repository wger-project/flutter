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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/providers/routines.dart';

/// Input widget for repetition units
///
/// Can be used with a Setting or a Log object
class RepetitionUnitInputWidget extends StatefulWidget {
  final RepetitionUnit? initialRepetitionUnit;
  final ValueChanged<RepetitionUnit> onChanged;

  const RepetitionUnitInputWidget(this.initialRepetitionUnit, {super.key, required this.onChanged});

  @override
  _RepetitionUnitInputWidgetState createState() => _RepetitionUnitInputWidgetState();
}

class _RepetitionUnitInputWidgetState extends State<RepetitionUnitInputWidget> {
  @override
  Widget build(BuildContext context) {
    final unitProvider = context.read<RoutinesProvider>();

    RepetitionUnit? selectedWeightUnit = widget.initialRepetitionUnit;

    return DropdownButtonFormField(
      initialValue: selectedWeightUnit,
      decoration: InputDecoration(labelText: AppLocalizations.of(context).repetitionUnit),
      isDense: true,
      onChanged: (RepetitionUnit? newValue) {
        if (newValue == null) {
          return;
        }

        setState(() {
          selectedWeightUnit = newValue;
          widget.onChanged(newValue);
        });
      },
      items: unitProvider.repetitionUnits.map<DropdownMenuItem<RepetitionUnit>>((
        RepetitionUnit value,
      ) {
        return DropdownMenuItem<RepetitionUnit>(
          key: Key(value.id.toString()),
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}
