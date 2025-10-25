/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020, 2020- wger Team
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
import 'package:wger/providers/network_provider.dart';

class DashboardNetworkInfo extends ConsumerWidget {
  const DashboardNetworkInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(networkStatusProvider);
    final i18n = AppLocalizations.of(context);

    return isOnline
        ? const SizedBox.shrink()
        : Tooltip(
            margin: const EdgeInsets.all(8),
            message: i18n.offlineModeInfo,
            child: Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  spacing: 8,
                  children: [
                    const Icon(Icons.info_outline),
                    Text(i18n.youAreOffline),
                  ],
                ),
              ),
            ),
          );
  }
}
