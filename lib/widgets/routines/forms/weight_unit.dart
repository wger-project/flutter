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
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/providers/routines.dart';

/// Input widget for workout weight units
///
/// Can be used with a Setting or a Log object
class WeightUnitInputWidget extends StatefulWidget {
  late int? selectedWeightUnit;
  final ValueChanged<int?> onChanged;

  WeightUnitInputWidget(initialValue, {required this.onChanged}) {
    selectedWeightUnit = initialValue;
  }

  @override
  _WeightUnitInputWidgetState createState() => _WeightUnitInputWidgetState();
}

class _WeightUnitInputWidgetState extends State<WeightUnitInputWidget> {
  @override
  Widget build(BuildContext context) {
    final unitProvider = context.read<RoutinesProvider>();

    WeightUnit? selectedWeightUnit = widget.selectedWeightUnit != null
        ? unitProvider.findWeightUnitById(widget.selectedWeightUnit!)
        : null;

    return DropdownButtonFormField(
      value: selectedWeightUnit,
      decoration: InputDecoration(labelText: AppLocalizations.of(context).weightUnit),
      onChanged: (WeightUnit? newValue) {
        setState(() {
          selectedWeightUnit = newValue!;
          widget.selectedWeightUnit = newValue.id;
          widget.onChanged(newValue.id);
        });
      },
      items: Provider.of<RoutinesProvider>(context, listen: false).weightUnits
          .map<DropdownMenuItem<WeightUnit>>((WeightUnit value) {
            return DropdownMenuItem<WeightUnit>(
              key: Key(value.id.toString()),
              value: value,
              child: Text(value.name),
            );
          })
          .toList(),
    );
  }
}
