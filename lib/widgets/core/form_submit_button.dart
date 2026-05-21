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

import 'package:flutter/material.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/helpers/errors.dart';
import 'package:wger/widgets/core/progress_indicator.dart';

/// Submit button that owns the saving and error state of an async form action.
///
/// While [onPressed] is in flight the button is disabled and renders a
/// [FormProgressIndicator], which also prevents a double submit. A
/// [WgerHttpException] thrown by [onPressed] is caught and rendered as a
/// [FormHttpErrorsWidget] directly above the button, other errors propagate
/// to the global error handler. Set [enabled] to false to disable the button
/// for other reasons, e.g. while offline.
class FormSubmitButton extends StatefulWidget {
  const FormSubmitButton({
    required this.onPressed,
    required this.label,
    this.enabled = true,
    super.key,
  });

  /// Async submit action. The spinner is shown until the returned future
  /// completes. A [WgerHttpException] is rendered inline; any other error is
  /// left to propagate.
  final Future<void> Function() onPressed;

  final String label;

  /// When false the button is disabled regardless of the saving state.
  final bool enabled;

  @override
  State<FormSubmitButton> createState() => _FormSubmitButtonState();
}

class _FormSubmitButtonState extends State<FormSubmitButton> {
  bool _isSaving = false;
  WgerHttpException? _error;

  Future<void> _handlePressed() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await widget.onPressed();
    } on WgerHttpException catch (error) {
      if (mounted) {
        setState(() => _error = error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_error != null) FormHttpErrorsWidget(_error!),
        ElevatedButton(
          onPressed: _isSaving || !widget.enabled ? null : _handlePressed,
          child: _isSaving ? const FormProgressIndicator() : Text(widget.label),
        ),
      ],
    );
  }
}
