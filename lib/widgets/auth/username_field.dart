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
import 'package:flutter/services.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

class UsernameField extends StatelessWidget {
  final TextEditingController controller;

  const UsernameField({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('inputUsername'),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).username,
        errorMaxLines: 2,
        prefixIcon: const Icon(Icons.account_circle),
      ),
      autofillHints: const [AutofillHints.username],
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context).invalidUsername;
        }
        if (!RegExp(r'^[\w.@+-]+$').hasMatch(value)) {
          return AppLocalizations.of(context).usernameValidChars;
        }
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
      ],
    );
  }
}
