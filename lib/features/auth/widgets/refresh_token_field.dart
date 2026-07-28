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

/// Three dot-separated base64url segments: the standard JWT shape, which
/// covers the refresh tokens issued by `allauth.headless`. Permissive on
/// length so future format changes do not lock users out.
final RegExp _jwtShape = RegExp(r'^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$');

class RefreshTokenField extends StatefulWidget {
  final TextEditingController controller;

  const RefreshTokenField({required this.controller, super.key});

  @override
  State<RefreshTokenField> createState() => _RefreshTokenFieldState();
}

class _RefreshTokenFieldState extends State<RefreshTokenField> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return TextFormField(
      key: const ValueKey('inputRefreshToken'),
      decoration: InputDecoration(
        labelText: i18n.refreshToken,
        helperText: i18n.refreshTokenHelperText,
        errorMaxLines: 2,
        helperMaxLines: 3,
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
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return i18n.invalidRefreshToken;
        }
        if (!_jwtShape.hasMatch(value)) {
          return i18n.refreshTokenValidChars;
        }
        return null;
      },
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
    );
  }
}
