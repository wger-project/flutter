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

import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

/// Read-only account information fetched from the REST `userprofile` endpoint.
///
/// These fields live on Django's `User` model rather than `core_userprofile`,
/// so they cannot travel through PowerSync. Editable preferences are kept
/// separately in the synced `UserProfile`.
@JsonSerializable(createToJson: false)
class Account {
  @JsonKey(required: true)
  final String username;

  @JsonKey(required: true)
  final String email;

  @JsonKey(required: true, name: 'email_verified')
  final bool emailVerified;

  @JsonKey(required: true, name: 'is_trustworthy')
  final bool isTrustworthy;

  const Account({
    required this.username,
    required this.email,
    required this.emailVerified,
    required this.isTrustworthy,
  });

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
}
