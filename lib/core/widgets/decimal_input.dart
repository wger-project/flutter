/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/formatting/formatting.dart';
import 'package:wger/core/number_input.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Locale-aware decimal text field.
///
/// Renders [value] with the active locale's number format and reports edits
/// through [onChanged] as a parsed [num], or null when the field is empty.
/// Display and parsing always go through the same NumberFormat, so a value can
/// never be mis-read because of a decimal-separator mismatch between locales.
///
/// [value] seeds the field, later changes to it are ignored: what the user
/// typed is what stands.
class DecimalInputWidget extends StatefulWidget {
  const DecimalInputWidget({
    required this.value,
    required this.onChanged,
    required this.labelText,
    this.suffixText,
    this.isRequired = false,
    this.min,
    this.max,
    this.steppers = const [],
    super.key,
  });

  /// The current value, or null when unset.
  final num? value;

  /// Called with the parsed value on every edit, or null when the field is
  /// cleared or its contents cannot be parsed.
  final ValueChanged<num?> onChanged;

  final String labelText;

  final String? suffixText;

  /// When true, an empty field fails validation instead of being accepted.
  final bool isRequired;

  /// Optional inclusive lower bound. When both [min] and [max] are set, a
  /// parsed value outside the range fails validation.
  final num? min;

  /// Optional inclusive upper bound. See [min].
  final num? max;

  /// Step sizes for the quick +/- buttons around the field, biggest first.
  /// Empty for a plain field.
  final List<num> steppers;

  @override
  State<DecimalInputWidget> createState() => _DecimalInputWidgetState();
}

class _DecimalInputWidgetState extends State<DecimalInputWidget> {
  /// Controller rather than `initialValue`, because the steppers write into
  /// the field. Seeded in didChangeDependencies, which is where the locale
  /// that formats the value is available.
  final _controller = TextEditingController();
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_seeded) {
      _seeded = true;
      final value = widget.value;
      if (value != null) {
        _controller.text = localizedNumberFormat(context).format(value);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Adds [delta] to what the field currently holds, unless that leaves the
  /// valid range or the field holds nothing to add to.
  void _step(num delta) {
    final numberFormat = localizedNumberFormat(context);
    final parsed = numberFormat.tryParse(_controller.text);
    if (parsed == null) {
      return;
    }

    final stepped = parsed + delta;
    if ((widget.min != null && stepped < widget.min!) ||
        (widget.max != null && stepped > widget.max!)) {
      return;
    }

    _controller.text = numberFormat.format(stepped);
    // Setting the text does not run the field's onChanged
    widget.onChanged(stepped);
  }

  /// The quick-change buttons of one side, biggest step outermost. The biggest
  /// one is drawn as a circled icon, so the two sizes stay apart at a glance.
  List<Widget> _stepperButtons({required bool plus}) => [
    for (final (index, step) in widget.steppers.indexed)
      IconButton(
        key: Key('stepper-${plus ? 'plus' : 'minus'}-$index'),
        icon: FaIcon(
          switch ((index, plus)) {
            (0, false) => FontAwesomeIcons.circleMinus,
            (0, true) => FontAwesomeIcons.circlePlus,
            (_, false) => FontAwesomeIcons.minus,
            (_, true) => FontAwesomeIcons.plus,
          },
        ),
        onPressed: () => _step(plus ? step : -step),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final numberFormat = localizedNumberFormat(context);
    final hasSteppers = widget.steppers.isNotEmpty;

    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixText: widget.suffixText,
        prefix: hasSteppers
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: _stepperButtons(plus: false),
              )
            : null,
        suffix: hasSteppers
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: _stepperButtons(plus: true).reversed.toList(),
              )
            : null,
      ),
      keyboardType: textInputTypeDecimal,
      inputFormatters: [LocalizedDecimalInputFormatter(numberFormat.symbols.DECIMAL_SEP)],
      onChanged: (text) {
        final trimmed = text.trim();
        widget.onChanged(trimmed.isEmpty ? null : numberFormat.tryParse(trimmed));
      },
      validator: (text) {
        final trimmed = text?.trim() ?? '';
        if (trimmed.isEmpty) {
          return widget.isRequired ? i18n.enterValue : null;
        }
        final parsed = numberFormat.tryParse(trimmed);
        if (parsed == null) {
          return i18n.enterValidNumber;
        }
        if (widget.min != null &&
            widget.max != null &&
            (parsed < widget.min! || parsed > widget.max!)) {
          return i18n.formMinMaxValues(widget.min!.toInt(), widget.max!.toInt());
        }
        return null;
      },
    );
  }
}
