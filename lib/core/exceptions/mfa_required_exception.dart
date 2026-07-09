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

/// Thrown when an `allauth.headless` login or signup response indicates that
/// the user must complete a second authentication factor before the session
/// can be issued tokens.
///
/// The [sessionToken] carries the short-lived flow handle that the follow-up
/// call to `auth/2fa/authenticate` must echo back. [availableFactors] lists
/// the supported factor ids ('totp', 'recovery_codes', 'webauthn') when the
/// server included them, so the UI can pick the right input affordance.
class MfaRequiredException implements Exception {
  final String sessionToken;
  final List<String> availableFactors;

  const MfaRequiredException({required this.sessionToken, this.availableFactors = const []});

  @override
  String toString() => 'MfaRequiredException(factors: $availableFactors, sessionToken: <redacted>)';
}
