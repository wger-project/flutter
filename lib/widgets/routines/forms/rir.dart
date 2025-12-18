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
import 'package:logging/logging.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/slot_entry.dart';

/// Input widget for Reps In Reserve
class RiRInputWidget extends StatefulWidget {
  final _logger = Logger('RiRInputWidget');

  final num? _initialValue;
  final ValueChanged<String> onChanged;

  static const SLIDER_START = -0.5;

  RiRInputWidget(this._initialValue, {super.key, required this.onChanged}) {
    _logger.finer('Initializing with initial value: $_initialValue');
  }

  @override
  _RiRInputWidgetState createState() => _RiRInputWidgetState();
}

class _RiRInputWidgetState extends State<RiRInputWidget> {
  late double _currentSetSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSetSliderValue = widget._initialValue?.toDouble() ?? RiRInputWidget.SLIDER_START;
    widget._logger.finer('initState - starting slider value: ${widget._initialValue}');
  }

  @override
  void didUpdateWidget(covariant RiRInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newValue = widget._initialValue?.toDouble() ?? RiRInputWidget.SLIDER_START;
    if (widget._initialValue != oldWidget._initialValue) {
      widget._logger.finer('didUpdateWidget - new initial value: ${widget._initialValue}');
      setState(() {
        _currentSetSliderValue = newValue;
      });
    }
  }

  /// Returns the string used in the slider
  String getSliderLabel(double value) {
    if (value < 0) {
      return AppLocalizations.of(context).rirNotUsed;
    }
    if (value > 4) {
      return '4+ ${AppLocalizations.of(context).rir}';
    }
    return '$value ${AppLocalizations.of(context).rir}';
  }

  String mapDoubleToAllowedRir(double value) {
    if (value < 0) {
      return '';
    }

    // The representation is different (3.0 -> 3) we are on an int, round
    if (value.toInt() < value) {
      return value.toString();
    }

    return value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(AppLocalizations.of(context).rir),
        Expanded(
          child: Slider(
            value: _currentSetSliderValue,
            min: RiRInputWidget.SLIDER_START,
            max: (SlotEntry.POSSIBLE_RIR_VALUES.length - 2) / 2,
            divisions: SlotEntry.POSSIBLE_RIR_VALUES.length - 1,
            label: getSliderLabel(_currentSetSliderValue),
            onChanged: (double value) {
              widget.onChanged(mapDoubleToAllowedRir(value));
              setState(() {
                _currentSetSliderValue = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
