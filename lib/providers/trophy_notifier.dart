/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/trophies/trophy.dart';
import 'package:wger/models/trophies/user_trophy.dart';
import 'package:wger/models/trophies/user_trophy_progression.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/providers/trophy_repository.dart';

part 'trophy_notifier.g.dart';

class TrophyState {
  final List<Trophy> trophies;
  final List<UserTrophy> userTrophies;
  final List<UserTrophyProgression> trophyProgression;

  TrophyState({
    this.trophies = const [],
    this.userTrophies = const [],
    this.trophyProgression = const [],
  });

  TrophyState copyWith({
    List<Trophy>? trophies,
    List<UserTrophy>? userTrophies,
    List<UserTrophyProgression>? trophyProgression,
  }) {
    return TrophyState(
      trophies: trophies ?? this.trophies,
      userTrophies: userTrophies ?? this.userTrophies,
      trophyProgression: trophyProgression ?? this.trophyProgression,
    );
  }

  List<UserTrophy> get prTrophies =>
      userTrophies.where((t) => t.trophy.type == TrophyType.pr).toList();

  List<UserTrophy> get nonPrTrophies =>
      userTrophies.where((t) => t.trophy.type != TrophyType.pr).toList();
}

@Riverpod(keepAlive: true)
final class TrophyStateNotifier extends _$TrophyStateNotifier {
  final _logger = Logger('TrophyStateNotifier');

  @override
  TrophyState build() {
    // Trophies are REST-only. Kick off the initial load when the server is
    // reachable, and (re)fetch once it becomes reachable again. Skipping the
    // fetch while offline keeps the REST calls from hammering an unreachable
    // server.
    if (ref.read(networkStatusProvider)) {
      Future.microtask(_fetchAllSafe);
    }
    ref.listen(networkStatusProvider, (previous, next) {
      if (next && previous == false) {
        Future.microtask(_fetchAllSafe);
      }
    });

    return TrophyState();
  }

  /// Runs [fetchAll], swallowing errors so a failed network load doesn't
  /// surface as an uncaught provider exception.
  Future<void> _fetchAllSafe() async {
    try {
      await fetchAll();
    } catch (e, s) {
      _logger.warning('trophy fetch failed', e, s);
    }
  }

  Future<void> fetchAll({String? language}) async {
    await Future.wait([
      fetchTrophies(language: language),
      fetchUserTrophies(language: language),
      fetchTrophyProgression(language: language),
    ]);
  }

  /// Fetch all available trophies
  Future<List<Trophy>> fetchTrophies({String? language}) async {
    _logger.finer('Fetching trophies');

    final repo = ref.read(trophyRepositoryProvider);
    final result = await repo.fetchTrophies(language: language);
    state = state.copyWith(trophies: result);
    return result;
  }

  /// Fetch trophies awarded to the user, excludes hidden trophies
  Future<List<UserTrophy>> fetchUserTrophies({String? language}) async {
    _logger.finer('Fetching user trophies');

    final repo = ref.read(trophyRepositoryProvider);
    final result = await repo.fetchUserTrophies(
      filterQuery: {'trophy__is_hidden': 'false'}, //'trophy__is_repeatable': 'false'
      language: language,
    );
    state = state.copyWith(userTrophies: result);
    return result;
  }

  /// Fetch trophy progression for the user
  Future<List<UserTrophyProgression>> fetchTrophyProgression({String? language}) async {
    _logger.finer('Fetching user trophy progression');

    // Note that repeatable trophies are filtered out in the backend
    final repo = ref.read(trophyRepositoryProvider);
    final result = await repo.fetchProgression(language: language);
    state = state.copyWith(trophyProgression: result);
    return result;
  }
}
