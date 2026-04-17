/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:http/http.dart' as http;
import 'package:wger/providers/base_provider.dart';

/// Builds a [WgerBaseProvider] pre-configured for tests with a fixed server
/// URL and API token. Pass a mocked [http.Client] to intercept requests.
WgerBaseProvider buildTestBaseProvider({
  http.Client? client,
  String serverUrl = 'https://localhost',
  String token = 'FooBar',
}) {
  return WgerBaseProvider(
    serverUrl: serverUrl,
    token: token,
    client: client,
  );
}
