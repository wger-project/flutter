/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2025 wger Team
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
import 'package:wger/models/trophies/trophy.dart';
import 'package:wger/providers/trophies.dart';
import 'package:wger/widgets/core/progress_indicator.dart';

class DashboardTrophiesWidget extends ConsumerWidget {
  const DashboardTrophiesWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(trophyStateProvider.notifier);

    return FutureBuilder(
      future: provider.fetchUserTrophies(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState != ConnectionState.done) {
          return const Card(child: BoxedProgressIndicator());
        }

        final userTrophies = asyncSnapshot.data ?? [];

        return Card(
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ListTile(
              //   title: Text(
              //     'Trophies',
              //     style: Theme.of(context).textTheme.headlineSmall,
              //   ),
              // ),
              if (userTrophies.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('No trophies yet', style: Theme.of(context).textTheme.bodyMedium),
                )
              else
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: userTrophies.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final userTrophy = userTrophies[index];

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
      },
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
    );
  }
}
