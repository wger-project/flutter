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

class UserProfileForm extends StatefulWidget {
  late Profile _profile;

  UserProfileForm() {
    //_weightEntry = weightEntry ?? WeightEntry(date: DateTime.now());
    //weightController.text = _weightEntry.id == null ? '' : _weightEntry.weight.toString();
    //dateController.text = toDate(_weightEntry.date)!;
  }

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _form = GlobalKey<FormState>();

  final dateController = TextEditingController();

  final weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    widget._profile = context.read<UserProvider>().profile!;

    return Form(
      key: _form,
      child: Column(
        children: [
          // Weight date
          SwitchListTile(
            title: Text(AppLocalizations.of(context).verifiedEmail),
            subtitle: Text(AppLocalizations.of(context).verifiedEmailReason),
            value: widget._profile.emailVerified,
            onChanged: (bool value) async {
              // Email is already verified
              if (widget._profile.emailVerified) {
                return;
              }

              // Verify
              await context.read<UserProvider>().verifyEmail();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).verifiedEmailInfo(widget._profile.email),
                  ),
                ),
              );
            },
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
              //context.read<UserProvider>().updateProfile();

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
