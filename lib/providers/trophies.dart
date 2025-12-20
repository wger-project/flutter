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

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/trophies/trophy.dart';
import 'package:wger/models/trophies/user_trophy.dart';
import 'package:wger/models/trophies/user_trophy_progression.dart';
import 'package:wger/providers/wger_base_riverpod.dart';

import 'base_provider.dart';

part 'trophies.g.dart';

class TrophyRepository {
  final WgerBaseProvider base;
  final trophiesPath = 'trophy';
  final userTrophiesPath = 'user-trophy';
  final userTrophyProgressionPath = 'trophy/progress';

  TrophyRepository(this.base);

  Future<List<Trophy>> fetchTrophies() async {
    final url = base.makeUrl(trophiesPath, query: {'limit': API_MAX_PAGE_SIZE});
    final trophyData = await base.fetchPaginated(url);
    return trophyData.map((e) => Trophy.fromJson(e)).toList();
  }

  Future<List<UserTrophy>> fetchUserTrophies() async {
    final url = base.makeUrl(userTrophiesPath, query: {'limit': API_MAX_PAGE_SIZE});
    final trophyData = await base.fetchPaginated(url);
    return trophyData.map((e) => UserTrophy.fromJson(e)).toList();
  }

  Future<List<UserTrophyProgression>> fetchProgression() async {
    final url = base.makeUrl(userTrophyProgressionPath, query: {'limit': API_MAX_PAGE_SIZE});
    final data = await base.fetchPaginated(url);
    return data.map((e) => UserTrophyProgression.fromJson(e)).toList();
  }

  List<Trophy> filterByType(List<Trophy> list, TrophyType type) =>
      list.where((t) => t.type == type).toList();
}

@riverpod
TrophyRepository trophyRepository(Ref ref) {
  final base = ref.read(wgerBaseProvider);
  return TrophyRepository(base);
}

@Riverpod(keepAlive: true)
final class TrophyStateNotifier extends _$TrophyStateNotifier {
  @override
  void build() {}

  /// Fetch all available trophies
  Future<List<Trophy>> fetchTrophies() async {
    final repo = ref.read(trophyRepositoryProvider);
    return repo.fetchTrophies();
  }

  /// Fetch trophies awarded to the user
  Future<List<UserTrophy>> fetchUserTrophies() async {
    final repo = ref.read(trophyRepositoryProvider);
    return repo.fetchUserTrophies();
  }

  /// Fetch trophy progression for the user
  Future<List<UserTrophyProgression>> fetchTrophyProgression() async {
    final repo = ref.read(trophyRepositoryProvider);
    return repo.fetchProgression();
  }
}
