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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/auth_notifier.dart';

/// Shown when auto-login fails outright (e.g. a transient blip on a startup
/// probe). Keeps the failure recoverable with a retry, instead of stranding
/// the user on a dead error screen that only a full app restart can clear.
class AutoLoginErrorScreen extends ConsumerWidget {
  const AutoLoginErrorScreen({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('$error', textAlign: TextAlign.center),
            ),
            FilledButton(
              onPressed: () => ref.read(authProvider.notifier).retryAutoLogin(),
              child: Text(AppLocalizations.of(context).serverUnreachableRetry),
            ),
          ],
        ),
      ),
    );
  }
}
