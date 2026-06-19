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

class ConfirmPasswordField extends StatefulWidget {
  final TextEditingController controller;

  /// The password field this entry must match.
  final TextEditingController passwordController;

  const ConfirmPasswordField({
    required this.controller,
    required this.passwordController,
    super.key,
  });

  @override
  State<ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('inputPassword2'),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).confirmPassword,
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
      validator: (value) {
        if (value != widget.passwordController.text) {
          return AppLocalizations.of(context).passwordsDontMatch;
        }
        return null;
      },
    );
  }
}
