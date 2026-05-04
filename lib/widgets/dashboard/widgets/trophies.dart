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
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/trophies/trophy.dart';
import 'package:wger/providers/trophies.dart';
import 'package:wger/screens/trophy_screen.dart';

class DashboardTrophiesWidget extends ConsumerWidget {
  const DashboardTrophiesWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trophiesState = ref.read(trophyStateProvider);
    final i18n = AppLocalizations.of(context);

    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trophiesState.nonPrTrophies.isEmpty)
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      i18n.trophies,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    // leading: Icon(Icons.widgets_outlined),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      i18n.noTrophies,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 140,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                scrollDirection: Axis.horizontal,
                itemCount: trophiesState.nonPrTrophies.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final userTrophy = trophiesState.nonPrTrophies[index];

                  return SizedBox(
                    width: 220,
                    child: TrophyCard(trophy: userTrophy.trophy),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class TrophyCard extends StatelessWidget {
  const TrophyCard({
    super.key,
    required this.trophy,
  });

  final Trophy trophy;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(TrophyScreen.routeName);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(trophy.image),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          trophy.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trophy.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
