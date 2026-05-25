/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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
import 'package:package_info_plus/package_info_plus.dart';

part 'auth_state.freezed.dart';

enum AuthStatus {
  loggedOut,
  loggedIn,

  // The app used to connect to a wger instance is too old and must be updated
  appUpdateRequired,

  // The wger server the app is configured to connect to is too old and must be updated
  serverUpdateRequired,

  /// The wger server is reachable, but the PowerSync service it points us
  /// at is not, and the user has never completed a full sync, so we have
  /// no local data to show.
  powerSyncUnreachable,
}

enum LoginActions {
  update,
  proceed,
}

/// Distinguishes which auth credential is currently active.
///
/// The app supports two parallel auth surfaces during the headless-allauth
/// migration: the legacy permanent DRF token (`/api/v2/login/` or pasted by
/// hand) and the short-lived JWT issued by `allauth.headless`. The HTTP
/// client branches on this to pick the right `Authorization` header.
enum AuthTokenType {
  /// Permanent DRF token, sent as `Authorization: Token <token>`.
  legacyApiToken,

  /// Short-lived JWT from `allauth.headless`, sent as `Authorization: Bearer <jwt>`.
  /// Refresh token lives in secure storage, not in state.
  headlessJwt,
}

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.loggedOut) AuthStatus status,
    String? token,
    String? accessToken,
    DateTime? accessExpiresAt,
    AuthTokenType? tokenType,
    String? serverUrl,
    String? serverVersion,
    PackageInfo? applicationVersion,
    @Default(false) bool serverConfigWarning,
  }) = _AuthState;

  const AuthState._();

  bool get isAuth => token != null || accessToken != null;
}
