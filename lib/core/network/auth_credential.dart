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

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wger/core/network/jwt.dart';

part 'auth_credential.freezed.dart';

/// Credential carried inside `AuthState` for every authenticated caller: a
/// short-lived access token from `allauth.headless`, sent as
/// `Authorization: Bearer <jwt>`. The refresh token is not part of it, it
/// lives in secure storage.
///
/// Every entry point (login, signup, MFA completion, pasted-refresh
/// exchange, auto-login from storage) produces one of these.
@freezed
abstract class JwtCredential with _$JwtCredential {
  const factory JwtCredential({
    required String accessToken,
    DateTime? expiresAt,
  }) = _JwtCredential;

  const JwtCredential._();

  /// `Authorization` header value for outgoing authenticated requests.
  String get authHeaderValue => 'Bearer $accessToken';

  /// True when the expiry falls within [leeway] of now, or is already past.
  /// False when the token carries no expiry at all.
  bool needsRefresh(Duration leeway) =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now().toUtc().add(leeway));

  /// User identifier carried by the token: its `sub` claim. Decoded on
  /// every call, so callers should not hammer it in tight loops. Null when
  /// the token isn't decodable or carries no `sub`.
  String? get userId => decodeJwtPayload(accessToken)?['sub']?.toString();
}
