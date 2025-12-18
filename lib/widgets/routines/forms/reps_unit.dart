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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/providers/routines.dart';

/// Input widget for repetition units
///
/// Can be used with a Setting or a Log object
class RepetitionUnitInputWidget extends ConsumerStatefulWidget {
  late int? selectedRepetitionUnit;
  final ValueChanged<int?> onChanged;

  RepetitionUnitInputWidget(int? initialValue, {super.key, required this.onChanged}) {
    selectedRepetitionUnit = initialValue;
  }

  @override
  _RepetitionUnitInputWidgetState createState() => _RepetitionUnitInputWidgetState();
}

class _RepetitionUnitInputWidgetState extends ConsumerState<RepetitionUnitInputWidget> {
  @override
  Widget build(BuildContext context) {
    final repUnits = ref.watch(routineRepetitionUnitProvider).asData?.value ?? [];

    RepetitionUnit? selectedWeightUnit = widget.selectedRepetitionUnit != null
        ? repUnits.firstWhere((unit) => unit.id == widget.selectedRepetitionUnit)
        : null;

    return DropdownButtonFormField(
      initialValue: selectedWeightUnit,
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
      items: repUnits.map<DropdownMenuItem<RepetitionUnit>>((RepetitionUnit value) {
        return DropdownMenuItem<RepetitionUnit>(
          key: Key(value.id.toString()),
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}
