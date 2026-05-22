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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:wger/models/user/account.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/wger_base.dart';

const _PROFILE_URL = 'userprofile';
const _VERIFY_EMAIL = 'verify-email';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final base = ref.read(wgerBaseProvider);
  return AccountRepository(base);
});

/// Read access to the user's account data (username, email, verification
/// status). These fields live on Django's `User` model and stay on the REST
/// API.
class AccountRepository {
  final _logger = Logger('AccountRepository');
  final WgerBaseProvider _base;

  AccountRepository(this._base);

  /// Fetches the current user's account data from the server.
  Future<Account> fetchAccount() async {
    _logger.finer('Fetching user account');
    final data = await _base.fetch(_base.makeUrl(_PROFILE_URL));
    return Account.fromJson(data);
  }

  /// Triggers the server's verification email flow.
  Future<void> verifyEmail() async {
    _logger.finer('Requesting email verification');
    await _base.fetch(_base.makeUrl(_PROFILE_URL, objectMethod: _VERIFY_EMAIL));
  }
}
