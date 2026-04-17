/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2025 - 2026 wger Team
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
import 'package:wger/providers/auth_notifier.dart';
import 'package:wger/providers/base_provider.dart';

/// Central provider that builds a [WgerBaseProvider] from the current
/// [AuthNotifier] state. Consumers read this to make authenticated HTTP
/// requests. Rebuilds whenever the auth state changes.
///
/// Note: not using riverpod_generator here because the generated provider
/// class name would collide with [WgerBaseProvider] from base_provider.dart.
final wgerBaseProvider = Provider<WgerBaseProvider>((ref) {
  final auth = ref.watch(authProvider).value;
  return WgerBaseProvider(
    serverUrl: auth?.serverUrl,
    token: auth?.token,
    applicationVersion: auth?.applicationVersion,
  );
});
