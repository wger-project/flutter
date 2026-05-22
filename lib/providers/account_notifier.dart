/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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
import 'package:wger/models/user/account.dart';
import 'package:wger/providers/account_repository.dart';

part 'account_notifier.g.dart';

@Riverpod(keepAlive: true)
class AccountNotifier extends _$AccountNotifier {
  late AccountRepository _repo;

  @override
  Future<Account?> build() async {
    _repo = ref.read(accountRepositoryProvider);
    return _repo.fetchAccount();
  }

  /// Triggers the server's verification email flow.
  Future<void> verifyEmail() async {
    await _repo.verifyEmail();
  }

  /// Clears the cached account (e.g. on logout).
  void clear() {
    state = const AsyncData(null);
  }
}
