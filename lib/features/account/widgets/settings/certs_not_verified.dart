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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/core/app_settings_notifier.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/http_overrides.dart';
import 'package:wger/core/network/auth_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Warns that invalid TLS certificates are currently being accepted, naming the
/// host it applies to. Renders nothing while certificates are verified normally.
///
/// Read-only on purpose: the opt-in belongs to the login screen. Switching it off
/// here would cut the connection to the very server the user is logged into, and
/// getting back in would need a logout anyway.
class SettingsCertsNotVerified extends ConsumerWidget {
  const SettingsCertsNotVerified({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // The opt-in is watched to rebuild on a change; whether it actually takes
    // effect for this server is up to the override.
    final allowSelfSignedCerts = ref.watch(
      appSettingsProvider.select(
        (s) => s.value?.allowSelfSignedCerts ?? ALLOW_SELF_SIGNED_CERTS_DEFAULT,
      ),
    );
    final serverUrl = ref.watch(authProvider.select((s) => s.value?.serverUrl));
    final host = allowSelfSignedCerts ? WgerHttpOverrides.exemptHost(serverUrl) : null;

    if (host == null) {
      return const SizedBox.shrink();
    }

    return ListTile(
      textColor: theme.colorScheme.error,
      key: const ValueKey('certsNotVerifiedWarning'),
      leading: Icon(Icons.gpp_bad_outlined, color: theme.colorScheme.error),
      title: Text(i18n.certsNotVerifiedTitle),
      subtitle: Text(i18n.certsNotVerifiedDetail(host)),
    );
  }
}
