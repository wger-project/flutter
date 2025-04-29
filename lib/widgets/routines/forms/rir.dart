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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/slot_entry.dart';

/// Input widget for Reps In Reserve
class RiRInputWidget extends StatefulWidget {
  final num? _initialValue;
  final ValueChanged<String> onChanged;
  late String dropdownValue;
  late double _currentSetSliderValue;

  static const SLIDER_START = -0.5;

  RiRInputWidget(this._initialValue, {required this.onChanged}) {
    dropdownValue = _initialValue != null ? _initialValue!.toString() : SlotEntry.DEFAULT_RIR;

    // Read string RiR into a double
    if (_initialValue != null) {
      _currentSetSliderValue = _initialValue!.toDouble();
    } else {
      _currentSetSliderValue = SLIDER_START;
    }
  }

  @override
  _RiRInputWidgetState createState() => _RiRInputWidgetState();
}

class _RiRInputWidgetState extends State<RiRInputWidget> {
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
            value: widget._currentSetSliderValue,
            min: RiRInputWidget.SLIDER_START,
            max: (SlotEntry.POSSIBLE_RIR_VALUES.length - 2) / 2,
            divisions: SlotEntry.POSSIBLE_RIR_VALUES.length - 1,
            label: getSliderLabel(widget._currentSetSliderValue),
            onChanged: (double value) {
              widget.onChanged(mapDoubleToAllowedRir(value));
              setState(() {
                widget._currentSetSliderValue = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
