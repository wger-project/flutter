/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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
import 'package:wger/l10n/generated/app_localizations.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  /// Whether to reject passwords shorter than 8 characters. Only the
  /// registration form sets a minimum length; the login form must accept any
  /// non-empty password so existing accounts are never locked out.
  final bool enforceMinLength;

  const PasswordField({
    required this.controller,
    this.enforceMinLength = false,
    super.key,
  });

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('inputPassword'),
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).password,
        prefixIcon: const Icon(Icons.password),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              isObscure = !isObscure;
            });
          },
        ),
      ),
      obscureText: isObscure,
      controller: widget.controller,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).enterValue;
        }
        if (widget.enforceMinLength && value.length < 8) {
          return AppLocalizations.of(context).passwordTooShort;
        }
        return null;
      },
    );
  }
}
