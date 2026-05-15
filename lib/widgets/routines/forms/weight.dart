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
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/i18n.dart';
import 'package:wger/helpers/number_input.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/workouts/weight_unit.dart';
import 'package:wger/providers/routines_notifier.dart';

/// Input widget for workout weight units
///
/// Can be used with a Setting or a Log object
class WeightUnitInputWidget extends ConsumerStatefulWidget {
  final WeightUnit? selectedWeightUnit;
  final ValueChanged<WeightUnit> onChanged;

  const WeightUnitInputWidget(this.selectedWeightUnit, {super.key, required this.onChanged});

  @override
  _WeightUnitInputWidgetState createState() => _WeightUnitInputWidgetState();
}

class _WeightUnitInputWidgetState extends ConsumerState<WeightUnitInputWidget> {
  @override
  Widget build(BuildContext context) {
    final units = ref.watch(routineWeightUnitProvider).asData?.value ?? <WeightUnit>[];

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
      items: units.map<DropdownMenuItem<WeightUnit>>((WeightUnit value) {
        return DropdownMenuItem<WeightUnit>(
          key: Key(value.id.toString()),
          value: value,
          child: Text(value.name),
        );
      }).toList(),
    );
  }
}

/// Controlled numeric input for weight
///
/// If both [unit] and [onUnitChanged] are provided, a compact dropdown listing
/// the values of [routineRepetitionUnitProvider] is rendered as the suffix of
/// the text field. If [onUnitChanged] is null, the dropdown is hidden and the
/// widget behaves as a pure numeric input.
class WeightInputWidget extends ConsumerStatefulWidget {
  final num? value;
  final ValueChanged<num?> onChanged;
  final WeightUnit? unit;
  final ValueChanged<WeightUnit?>? onUnitChanged;
  final num valueChange;
  final TextEditingController? controller;

  const WeightInputWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.unit,
    this.onUnitChanged,
    this.controller,
    num? valueChange,
  }) : valueChange = valueChange ?? 1.25;

  @override
  ConsumerState<WeightInputWidget> createState() => _WeightInputWidgetState();
}

class _WeightInputWidgetState extends ConsumerState<WeightInputWidget> {
  final _logger = Logger('WeightInputWidget');
  late TextEditingController _controller;
  late NumberFormat _numberFormat;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    // _numberFormat is finalised in didChangeDependencies once the locale
    // is available; the placeholder here keeps the field non-late-uninit.
    _numberFormat = NumberFormat.decimalPattern();
    if (widget.value != null) {
      _controller.text = _numberFormat.format(widget.value);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());
  }

  @override
  void didUpdateWidget(covariant WeightInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == oldWidget.value) {
      return;
    }
    // Setting `controller.text` notifies its listeners synchronously,
    // which in turn calls `setState` on the surrounding Form/TextField
    // state, and `didUpdateWidget` runs *during* the build cycle, so
    // that's illegal. Defer the assignment to after the current frame.
    final text = widget.value == null ? '' : _numberFormat.format(widget.value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (_controller.text != text) {
        _controller.text = text;
      }
    });
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
    final i18n = AppLocalizations.of(context);

    String labelText = i18n.weight;
    Widget? suffixIcon;
    final onUnitChanged = widget.onUnitChanged;
    if (onUnitChanged != null) {
      final units = ref.watch(routineWeightUnitProvider).asData?.value ?? <WeightUnit>[];
      if (units.isNotEmpty) {
        labelText = widget.unit == null
            ? i18n.weight
            : getServerStringTranslation(widget.unit!.name, context);
        suffixIcon = PopupMenuButton<int>(
          icon: const Icon(Icons.arrow_drop_down),
          tooltip: i18n.weightUnit,
          onSelected: (id) {
            onUnitChanged(units.firstWhere((u) => u.id == id));
          },
          itemBuilder: (context) => units
              .map(
                (u) => PopupMenuItem<int>(
                  value: u.id,
                  child: Text(getServerStringTranslation(u.name, context)),
                ),
              )
              .toList(),
        );
      }
    }

    return Row(
      children: [
        // "Quick-remove" button
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.black),
          iconSize: 25,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
          onPressed: () {
            final base = widget.value ?? 0;
            final newValue = base - widget.valueChange;
            if (newValue >= 0) {
              widget.onChanged(newValue);
            }
          },
        ),

        // Text field
        Expanded(
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: labelText,
              suffixIcon: suffixIcon,
              suffixIconConstraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              isDense: true,
            ),
            keyboardType: textInputTypeDecimal,
            inputFormatters: [LocalizedDecimalInputFormatter(_numberFormat.symbols.DECIMAL_SEP)],
            onChanged: (text) {
              if (text.isEmpty) {
                widget.onChanged(null);
                return;
              }
              try {
                widget.onChanged(_numberFormat.parse(text));
              } on FormatException catch (error) {
                _logger.finer('Error parsing weight: $error');
              }
            },
            onSaved: (text) {
              if (text == null || text.isEmpty) {
                return;
              }
              widget.onChanged(_numberFormat.parse(text));
            },
            validator: (text) {
              if (_numberFormat.tryParse(text ?? '') == null) {
                return i18n.enterValidNumber;
              }
              return null;
            },
          ),
        ),

        // "Quick-add" button
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          iconSize: 25,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
          onPressed: () {
            final base = widget.value ?? 0;
            final newValue = base + widget.valueChange;
            widget.onChanged(newValue);
          },
        ),
      ],
    );
  }
}
