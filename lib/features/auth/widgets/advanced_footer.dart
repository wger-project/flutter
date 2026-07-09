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
import 'package:wger/l10n/generated/app_localizations.dart';

/// "ADVANCED" footer line opening the advanced sheet. Shows an indicator dot
/// plus a suffix ("{host}" or "Token") when the selection deviates from
/// the default.
class AdvancedFooter extends StatelessWidget {
  final bool isCustomServer;
  final bool isTokenMode;
  final String serverUrl;
  final VoidCallback onTap;

  const AdvancedFooter({
    required this.isCustomServer,
    required this.isTokenMode,
    required this.serverUrl,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    String? suffix;
    if (isCustomServer) {
      suffix = serverUrl.trim().replaceFirst(RegExp(r'^https?://'), '');
    } else if (isTokenMode) {
      suffix = i18n.tokenLabel;
    }
    final active = suffix != null;
    return TextButton(
      key: const Key('advancedButton'),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            i18n.advanced.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (active) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '· $suffix',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: 14,
            color: theme.colorScheme.outline,
          ),
        ],
      ),
    );
  }
}
