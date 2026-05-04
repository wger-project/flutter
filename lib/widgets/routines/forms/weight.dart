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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/providers/gym_log_state.dart';
import 'package:wger/providers/plate_weights.dart';
import 'package:wger/providers/routines.dart';

/// Input widget for workout weight units
///
/// Can be used with a Setting or a Log object
class WeightUnitInputWidget extends StatefulWidget {
  final WeightUnit? selectedWeightUnit;
  final ValueChanged<WeightUnit> onChanged;

  const WeightUnitInputWidget(this.selectedWeightUnit, {super.key, required this.onChanged});

  @override
  _WeightUnitInputWidgetState createState() => _WeightUnitInputWidgetState();
}

class _WeightUnitInputWidgetState extends State<WeightUnitInputWidget> {
  @override
  Widget build(BuildContext context) {
    final unitProvider = context.read<RoutinesProvider>();

    WeightUnit? selectedWeightUnit = widget.selectedWeightUnit;

    return DropdownButtonFormField(
      initialValue: selectedWeightUnit,
      decoration: InputDecoration(labelText: AppLocalizations.of(context).weightUnit),
      onChanged: (WeightUnit? newValue) {
        if (newValue == null) {
          return;
        }

        setState(() {
          selectedWeightUnit = newValue;
          widget.onChanged(newValue);
        });
      },
      items: unitProvider.weightUnits.map<DropdownMenuItem<WeightUnit>>((WeightUnit value) {
        return DropdownMenuItem<WeightUnit>(
          key: Key(value.id.toString()),
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}

class WeightInputWidget extends ConsumerStatefulWidget {
  final num valueChange;
  final TextEditingController? controller;

  const WeightInputWidget({
    super.key,
    this.controller,
    num? valueChange,
  }) : valueChange = valueChange ?? 1.25;

  @override
  ConsumerState<WeightInputWidget> createState() => _WeightInputWidgetState();
}

class _WeightInputWidgetState extends ConsumerState<WeightInputWidget> {
  final _logger = Logger('LogsWeightWidget');
  late TextEditingController _controller;
  num? _lastWeight;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
    final i18n = AppLocalizations.of(context);

    final plateProvider = ref.read(plateCalculatorProvider.notifier);
    final logProvider = ref.read(gymLogProvider.notifier);
    final log = ref.watch(gymLogProvider);
    final currentWeight = log?.weight;

    // Only update when provider value changed
    if (currentWeight != _lastWeight) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        if (currentWeight != null) {
          _controller.text = numberFormat.format(currentWeight);
        } else {
          _controller.clear();
        }
        _lastWeight = currentWeight;
      });
    }

    return Row(
      children: [
        IconButton(
          // "Quick-remove" button
          icon: const Icon(Icons.remove, color: Colors.black),
          onPressed: () {
            final base = currentWeight ?? 0;
            final newValue = base - widget.valueChange;
            if (newValue >= 0 && log != null) {
              logProvider.setWeight(newValue);
            }
          },
        ),

        // Text field
        Expanded(
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(labelText: i18n.weight),
            keyboardType: textInputTypeDecimal,
            onChanged: (value) {
              try {
                final newValue = numberFormat.parse(value);
                plateProvider.setWeight(newValue);
                logProvider.setWeight(newValue);
              } on FormatException catch (error) {
                _logger.finer('Error parsing weight: $error');
              }
            },
            onSaved: (newValue) {
              if (newValue == null || log == null) {
                return;
              }
              logProvider.setWeight(numberFormat.parse(newValue));
            },
            validator: (value) {
              if (numberFormat.tryParse(value ?? '') == null) {
                return i18n.enterValidNumber;
              }
              return null;
            },
          ),
        ),

        // "Quick-add" button
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () {
            final base = currentWeight ?? 0;
            final newValue = base + widget.valueChange;
            if (log != null) {
              logProvider.setWeight(newValue);
            }
          },
        ),
      ],
    );
  }
}
