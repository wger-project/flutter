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
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/widgets/core/core.dart';

class AliasesSection extends StatelessWidget {
  final Translation translation;

  const AliasesSection({super.key, required this.translation});

  @override
  Widget build(BuildContext context) {
    if (translation.aliases.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MutedText(
          AppLocalizations.of(context).alsoKnownAs(
            translation.aliases.map((e) => e.alias).toList().join(', '),
          ),
        ),
        const SizedBox(height: 9),
      ],
    );
  }
}
