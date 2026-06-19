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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/app_settings_notifier.dart';

/// "Keep data on logout" toggle. When on, a logout keeps the local database
/// so the same user signing back in resumes the sync incrementally instead of
/// re-running the full first sync; a different user still triggers a wipe.
class SettingsDataPrivacy extends ConsumerWidget {
  const SettingsDataPrivacy({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final keepData = ref.watch(
      appSettingsProvider.select((s) => s.value?.keepDataOnLogout ?? KEEP_DATA_ON_LOGOUT_DEFAULT),
    );

    return SwitchListTile(
      key: const ValueKey('keepDataOnLogoutSwitch'),
      title: Text(i18n.settingsKeepDataOnLogout),
      subtitle: Text(i18n.settingsKeepDataOnLogoutDescription),
      value: keepData,
      onChanged: (value) => ref.read(appSettingsProvider.notifier).setKeepDataOnLogout(value),
    );
  }
}
