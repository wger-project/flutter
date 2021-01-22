/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:wger/providers/base_provider.dart';

import 'utils.dart';

void main() {
  group('test base provider', () {
    test('Test the makeUrl helper', () async {
      final WgerBaseProvider provider = WgerBaseProvider(testAuth);

      expect(
        'https://localhost/api/v2/endpoint/',
        provider.makeUrl('endpoint'),
      );
      expect(
        'https://localhost/api/v2/endpoint/5/',
        provider.makeUrl('endpoint', id: 5),
      );
      expect(
        'https://localhost/api/v2/endpoint/5/log_data/',
        provider.makeUrl('endpoint', id: 5, objectMethod: 'log_data'),
      );
      expect(
        'https://localhost/api/v2/endpoint/?a=2&b=c',
        provider.makeUrl('endpoint', query: {'a': '2', 'b': 'c'}),
      );
      expect(
        'https://localhost/api/v2/endpoint/log_data/?a=2&b=c',
        provider.makeUrl('endpoint', objectMethod: 'log_data', query: {'a': '2', 'b': 'c'}),
      );
      expect(
        'https://localhost/api/v2/endpoint/42/?a=2&b=c',
        provider.makeUrl('endpoint', id: 42, query: {'a': '2', 'b': 'c'}),
      );
      expect(
        'https://localhost/api/v2/endpoint/42/log_data/  ?a=2&b=c',
        provider.makeUrl('endpoint', id: 42, objectMethod: 'log_data', query: {'a': '2', 'b': 'c'}),
      );
    });
  });
}
