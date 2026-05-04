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
import 'package:wger/models/workouts/repetition_unit.dart';
import 'package:wger/providers/gym_log_state.dart';
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

class RepetitionInputWidget extends ConsumerStatefulWidget {
  final num valueChange;
  final TextEditingController? controller;

  const RepetitionInputWidget({
    super.key,
    this.controller,
    num? valueChange,
  }) : valueChange = valueChange ?? 1;

  @override
  ConsumerState<RepetitionInputWidget> createState() => _RepetitionInputWidgetState();
}

class _RepetitionInputWidgetState extends ConsumerState<RepetitionInputWidget> {
  final _logger = Logger('LogsRepsWidget');
  late TextEditingController _controller;
  num? _lastReps;

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

    final logNotifier = ref.read(gymLogProvider.notifier);
    final log = ref.watch(gymLogProvider);
    final currentReps = log?.repetitions;

    // Only update the controller when the provider value actually changed
    if (currentReps != _lastReps) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        if (currentReps != null) {
          _controller.text = numberFormat.format(currentReps);
        } else {
          _controller.clear();
        }
        _lastReps = currentReps;
      });
    }

    return Row(
      children: [
        // "Quick-remove" button
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.black),
          onPressed: () {
            final base = currentReps ?? 0;
            final newValue = base - widget.valueChange;
            if (newValue >= 0 && log != null) {
              logNotifier.setRepetitions(newValue);
            }
          },
        ),

        // Text field
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(labelText: i18n.repetitions),
            enabled: true,
            controller: _controller,
            keyboardType: textInputTypeDecimal,
            onChanged: (value) {
              try {
                final newValue = numberFormat.parse(value);
                logNotifier.setRepetitions(newValue);
              } on FormatException catch (error) {
                _logger.finer('Error parsing repetitions: $error');
              }
            },
            onSaved: (newValue) {
              if (newValue == null || log == null) {
                return;
              }
              logNotifier.setRepetitions(numberFormat.parse(newValue));
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
            final base = currentReps ?? 0;
            final newValue = base + widget.valueChange;
            if (newValue >= 0 && log != null) {
              logNotifier.setRepetitions(newValue);
            }
          },
        ),
      ],
    );
  }
}
