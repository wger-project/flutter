/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2025 wger Team
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
import 'package:wger/core/wide_screen_wrapper.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/trophies/trophies_overview.dart';

class TrophyScreen extends StatelessWidget {
  const TrophyScreen();

  static const routeName = '/trophies';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmptyAppBar(AppLocalizations.of(context).trophies),
      body: WidescreenWrapper(
        child: TrophiesOverview(),
      ),
    );
  }
}
