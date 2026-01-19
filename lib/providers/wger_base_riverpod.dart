/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2025 - 2025 wger Team
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
import 'package:wger/providers/auth.dart';
import 'package:wger/providers/base_provider.dart';

/// Central provider that maps an existing [AuthProvider] (from the provider package)
/// to a [WgerBaseProvider] used by repositories.
///
/// Usage: ref.watch(wgerBaseProvider(authProvider))
final wgerBaseProvider = Provider<WgerBaseProvider>((ref) {
  throw UnimplementedError(
    'Override wgerBaseProvider in a ProviderScope with your existing WgerBaseProvider instance',
  );
});
