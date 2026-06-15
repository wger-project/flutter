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
import 'package:url_launcher/url_launcher.dart';
import 'package:wger/helpers/misc.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/user/user_profile.dart';
import 'package:wger/providers/account_notifier.dart';
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/user_profile_notifier.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/core/form_submit_button.dart';

/// Shows the user's account data and lets them edit the profile preferences.
///
/// The weight-unit preference is persisted through PowerSync, so saving works
/// offline. The e-mail actions (change address, resend verification) go through
/// `allauth.headless` and therefore need the server.
class UserProfileForm extends ConsumerStatefulWidget {
  const UserProfileForm({super.key});

  @override
  ConsumerState<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends ConsumerState<UserProfileForm> {
  final _form = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  /// Pending weight-unit edit, null while it still mirrors the synced value.
  String? _weightUnitStr;

  /// The email field is seeded from the loaded account exactly once; later
  /// rebuilds must not clobber what the user typed.
  bool _emailInitialised = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final isOnline = ref.watch(networkStatusProvider);
    final account = ref.watch(accountProvider).value;
    final profile = ref.watch(userProfileProvider).value;

    if (account == null || profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_emailInitialised) {
      _emailController.text = account.email;
      _emailInitialised = true;
    }

    final weightUnitStr = _weightUnitStr ?? profile.weightUnitStr;
    final isMetric = weightUnitStr == 'kg';

    return Form(
      key: _form,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: wgerPrimaryColor),
            title: Text(i18n.username),
            subtitle: Text(account.username),
          ),
          SwitchListTile(
            title: Text(i18n.useMetric),
            subtitle: Text(weightUnitStr),
            value: isMetric,
            onChanged: (_) {
              setState(() {
                _weightUnitStr = isMetric ? 'lb' : 'kg';
              });
            },
            dense: true,
          ),
          ListTile(
            leading: const Icon(Icons.email_rounded, color: wgerPrimaryColor),
            title: TextFormField(
              decoration: InputDecoration(
                labelText: account.emailVerified ? i18n.verifiedEmail : i18n.unVerifiedEmail,
                suffixIcon: account.emailVerified
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              // Email changes go through the server; disable editing offline.
              enabled: isOnline,
              validator: (value) {
                if (value != null && value.isNotEmpty && !value.contains('@')) {
                  return i18n.invalidEmail;
                }
                return null;
              },
            ),
          ),
          if (!account.emailVerified)
            OutlinedButton(
              onPressed: isOnline
                  ? () async {
                      await ref.read(accountProvider.notifier).resendVerification(account.email);
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(i18n.verifiedEmailInfo(account.email)),
                        ),
                      );
                    }
                  : null,
              child: Text(i18n.verify),
            ),
          const Divider(height: 32),
          ListTile(
            key: const Key('manageAccountOnWebTile'),
            leading: const Icon(Icons.open_in_new, color: wgerPrimaryColor),
            title: Text(i18n.manageAccountOnWeb),
            subtitle: Text(i18n.manageAccountOnWebSubtitle),
            enabled: isOnline,
            onTap: () {
              final serverUrl = ref.read(authProvider).value?.serverUrl;
              if (serverUrl == null) {
                return;
              }
              launchURL(
                '$serverUrl/user/preferences',
                context,
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          const Divider(height: 32),
          FormSubmitButton(
            onPressed: () async {
              if (!_form.currentState!.validate()) {
                return;
              }

              // The weight unit is synced through PowerSync and saves offline.
              await ref
                  .read(userProfileProvider.notifier)
                  .updateProfile(
                    UserProfile(id: profile.id, weightUnitStr: weightUnitStr),
                  );

              // Changing the email needs the server: a verification mail is
              // sent and the new address only takes effect once confirmed. The
              // field is disabled offline, so this never runs without a server.
              final newEmail = _emailController.text.trim();
              final emailChanged = newEmail.isNotEmpty && newEmail != account.email;
              if (emailChanged) {
                await ref.read(accountProvider.notifier).requestEmailChange(newEmail);
                // Keep showing the old address until the server confirms it.
                _emailController.text = account.email;
              }

              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    emailChanged ? i18n.verifiedEmailInfo(newEmail) : i18n.successfullySaved,
                  ),
                ),
              );
            },
            label: i18n.save,
          ),
        ],
      ),
    );
  }
}
