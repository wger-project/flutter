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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/user/user_profile.dart';
import 'package:wger/providers/account_notifier.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/user_profile_notifier.dart';
import 'package:wger/theme/theme.dart';

/// Shows the user's account data (read-only) and lets them edit the profile
/// preferences. The weight-unit preference is persisted through PowerSync, so
/// saving works offline; the e-mail verification action still needs the server.
class UserProfileForm extends ConsumerStatefulWidget {
  const UserProfileForm({super.key});

  @override
  ConsumerState<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends ConsumerState<UserProfileForm> {
  /// Pending weight-unit edit, null while it still mirrors the synced value.
  String? _weightUnitStr;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final isOnline = ref.watch(networkStatusProvider);
    final account = ref.watch(accountProvider).value;
    final profile = ref.watch(userProfileProvider).value;

    if (account == null || profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final weightUnitStr = _weightUnitStr ?? profile.weightUnitStr;
    final isMetric = weightUnitStr == 'kg';

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person, color: wgerPrimaryColor),
          title: Text(i18n.username),
          subtitle: Text(account.username),
        ),
        ListTile(
          leading: const Icon(Icons.email_rounded, color: wgerPrimaryColor),
          title: Text(
            account.emailVerified ? i18n.verifiedEmail : i18n.unVerifiedEmail,
          ),
          subtitle: Text(account.email),
          trailing: account.emailVerified
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
        ),
        SwitchListTile(
          title: Text(i18n.useMetric),
          subtitle: Text(weightUnitStr),
          value: isMetric,
          onChanged: (_) {
            setState(() {
              _weightUnitStr = isMetric ? i18n.lb : i18n.kg;
            });
          },
          dense: true,
        ),
        if (!account.emailVerified)
          OutlinedButton(
            onPressed: isOnline
                ? () async {
                    await ref.read(accountProvider.notifier).verifyEmail();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(i18n.verifiedEmailInfo(account.email)),
                        ),
                      );
                    }
                  }
                : null,
            child: Text(i18n.verify),
          ),
        ElevatedButton(
          onPressed: () async {
            await ref
                .read(userProfileProvider.notifier)
                .updateProfile(
                  UserProfile(id: profile.id, weightUnitStr: weightUnitStr),
                );
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(i18n.successfullySaved)),
              );
            }
          },
          child: Text(i18n.save),
        ),
      ],
    );
  }
}
