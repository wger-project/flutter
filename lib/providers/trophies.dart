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
import 'package:wger/models/trophies/user_trophy_progression.dart';
import 'package:wger/providers/wger_base_riverpod.dart';

part 'trophies.g.dart';

@riverpod
Future<List<Trophy>> trophies(Ref ref) async {
  const trophiesPath = 'trophy';

  final baseProvider = ref.read(wgerBaseProvider);

  final trophyData = await baseProvider.fetchPaginated(
    baseProvider.makeUrl(trophiesPath, query: {'limit': API_MAX_PAGE_SIZE}),
  );

  return trophyData.map((e) => Trophy.fromJson(e)).toList();
}

@riverpod
Future<List<UserTrophyProgression>> trophyProgression(Ref ref) async {
  const userTrophyProgressionPath = 'trophy/progress';

  final baseProvider = ref.read(wgerBaseProvider);

  final trophyData = await baseProvider.fetchPaginated(
    baseProvider.makeUrl(userTrophyProgressionPath, query: {'limit': API_MAX_PAGE_SIZE}),
  );

  return trophyData.map((e) => UserTrophyProgression.fromJson(e)).toList();
}
