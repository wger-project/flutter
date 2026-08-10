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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/app_settings_notifier.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// "Detailed logging" toggle. When on, the application log also collects the
/// fine-grained diagnostic entries, which otherwise only exist in debug
/// builds. Persisted, so it also covers the phase right after a cold start.
class SettingsVerboseLogging extends ConsumerWidget {
  const SettingsVerboseLogging({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final verbose = ref.watch(
      appSettingsProvider.select((s) => s.value?.verboseLogging ?? VERBOSE_LOGGING_DEFAULT),
    );

    return SwitchListTile(
      key: const ValueKey('verboseLoggingSwitch'),
      title: Text(i18n.settingsVerboseLogging),
      subtitle: Text(i18n.settingsVerboseLoggingDescription),
      value: verbose,
      onChanged: (value) => ref.read(appSettingsProvider.notifier).setVerboseLogging(value),
    );
  }
}
