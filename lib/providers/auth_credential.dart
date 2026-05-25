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
import 'package:wger/helpers/jwt.dart';

part 'auth_credential.freezed.dart';

/// Sealed credential carried inside [AuthState] for every authenticated
/// caller. Branch via `switch` or `is` to access the variant-specific
/// fields; the two getters below cover everything the HTTP layer needs.
///
/// The app supports two flavours during the migration to `allauth.headless`:
///
/// - [LegacyCredential] — permanent DRF token from `/api/v2/login/`, sent
///   as `Authorization: Token <key>`. This is what existing installs are
///   running until they re-authenticate on a build that ships the JWT flow.
/// - [JwtCredential] — short-lived access token from `allauth.headless`,
///   sent as `Authorization: Bearer <jwt>`. The refresh token lives in
///   secure storage, not on the credential itself.
///
/// New logins (login, signup, MFA completion, pasted-refresh exchange)
/// always produce a [JwtCredential].
@freezed
sealed class AuthCredential with _$AuthCredential {
  const factory AuthCredential.legacy(String token) = LegacyCredential;

  const factory AuthCredential.jwt({
    required String accessToken,
    DateTime? expiresAt,
  }) = JwtCredential;

  const AuthCredential._();

  /// `Authorization` header value for outgoing authenticated requests.
  String get authHeaderValue => switch (this) {
    LegacyCredential(:final token) => 'Token $token',
    JwtCredential(:final accessToken) => 'Bearer $accessToken',
  };

  /// True when this credential is a JWT whose expiry falls within [leeway]
  /// of now (or is already past). Always false for [LegacyCredential]:
  /// permanent DRF tokens have no expiry and are never refreshed.
  bool needsRefresh(Duration leeway) => switch (this) {
    LegacyCredential() => false,
    JwtCredential(:final expiresAt) =>
      expiresAt != null && expiresAt.isBefore(DateTime.now().toUtc().add(leeway)),
  };

  /// User identifier carried by the credential. For [JwtCredential] this is
  /// the JWT `sub` claim (decoded on every call, so callers should not
  /// hammer it in tight loops). Null for [LegacyCredential]: permanent DRF
  /// tokens don't expose the user-id and the app discovers it lazily via
  /// the user-profile endpoint instead.
  String? get userId => switch (this) {
    LegacyCredential() => null,
    JwtCredential(:final accessToken) => decodeJwtPayload(accessToken)?['sub']?.toString(),
  };
}
