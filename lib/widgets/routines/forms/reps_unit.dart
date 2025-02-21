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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/providers/routines.dart';

/// Input widget for repetition units
///
/// Can be used with a Setting or a Log object
class RepetitionUnitInputWidget extends StatefulWidget {
  late int? selectedRepetitionUnit;
  final ValueChanged<int?> onChanged;

  RepetitionUnitInputWidget(initialValue, {required this.onChanged}) {
    selectedRepetitionUnit = initialValue;
  }

  @override
  _RepetitionUnitInputWidgetState createState() => _RepetitionUnitInputWidgetState();
}

class _RepetitionUnitInputWidgetState extends State<RepetitionUnitInputWidget> {
  @override
  Widget build(BuildContext context) {
    final unitProvider = context.read<RoutinesProvider>();

    RepetitionUnit? selectedWeightUnit = widget.selectedRepetitionUnit != null
        ? unitProvider.findRepetitionUnitById(widget.selectedRepetitionUnit!)
        : null;

    return DropdownButtonFormField(
      value: selectedWeightUnit,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).repetitionUnit,
      ),
      isDense: true,
      onChanged: (RepetitionUnit? newValue) {
        setState(() {
          selectedWeightUnit = newValue!;
          widget.selectedRepetitionUnit = newValue.id;
          widget.onChanged(newValue.id);
        });
      },
      items: Provider.of<RoutinesProvider>(context, listen: false)
          .repetitionUnits
          .map<DropdownMenuItem<RepetitionUnit>>((RepetitionUnit value) {
        return DropdownMenuItem<RepetitionUnit>(
          key: Key(value.id.toString()),
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}
