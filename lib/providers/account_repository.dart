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
const _HEADLESS_ACCOUNT_EMAIL = 'account/email';

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

  /// Starts an email-change flow against `allauth.headless`.
  ///
  /// Posting a new address queues it as a pending change: the server mails a
  /// verification link to [newEmail], and the new address only replaces the
  /// current one once the user clicks that link. Until then the account email
  /// is unchanged.
  Future<void> requestEmailChange(String newEmail) async {
    _logger.finer('Requesting email change');
    await _base.post({'email': newEmail}, _base.makeHeadlessUrl(_HEADLESS_ACCOUNT_EMAIL));
  }

  /// Asks the server to re-send the verification mail for [email]. Useful for
  /// users who signed up but never clicked the original link.
  Future<void> resendVerification(String email) async {
    _logger.finer('Re-sending email verification');
    await _base.put({'email': email}, _base.makeHeadlessUrl(_HEADLESS_ACCOUNT_EMAIL));
  }
}
