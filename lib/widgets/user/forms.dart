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
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/user/profile.dart';
import 'package:wger/providers/user.dart';

class UserProfileForm extends StatelessWidget {
  late final Profile _profile;
  final _form = GlobalKey<FormState>();
  final emailController = TextEditingController();

  UserProfileForm(Profile profile) {
    _profile = profile;
    emailController.text = _profile.email;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context).username),
            subtitle: Text(_profile.username),
          ),
          ListTile(
            title: Text(
              _profile.emailVerified
                  ? AppLocalizations.of(context).verifiedEmail
                  : AppLocalizations.of(context).unVerifiedEmail,
            ),
            subtitle: Text(AppLocalizations.of(context).verifiedEmailReason),
            trailing: _profile.emailVerified
                ? const Icon(Icons.mark_email_read, color: Colors.green)
                : const Icon(Icons.forward_to_inbox),
            onTap: () async {
              // Email is already verified
              if (_profile.emailVerified) {
                return;
              }

              // Verify
              await context.read<UserProvider>().verifyEmail();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).verifiedEmailInfo(_profile.email),
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: TextFormField(
              decoration: InputDecoration(labelText: AppLocalizations.of(context).email),
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              onSaved: (newValue) {
                _profile.email = newValue!;
              },
              validator: (value) {
                if (value!.isNotEmpty && !value.contains('@')) {
                  return AppLocalizations.of(context).invalidEmail;
                }
                return null;
              },
            ),
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              // Validate and save the current values to the weightEntry
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              // Update profile
              context.read<UserProvider>().saveProfile();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context).successfullySaved)),
              );
            },
          ),
        ],
      ),
    );
  }
}
