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
          return const Card(
            child: BoxedProgressIndicator(),
          );
        }

        return Card(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Trophies',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),

              ...(asyncSnapshot.data ?? []).map(
                (userTrophy) => ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userTrophy.trophy.image),
                  ),
                  title: Text(userTrophy.trophy.name),
                  subtitle: Text(userTrophy.trophy.description, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
