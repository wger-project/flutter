/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The text of the `one` branch of a plural message, null if it has none.
String? oneBranch(String message) {
  final start = message.indexOf(' one{');
  if (!message.startsWith(RegExp(r'\{\w+, plural,')) || start == -1) {
    return null;
  }
  final begin = start + ' one{'.length;
  var depth = 1;
  for (var i = begin; i < message.length; i++) {
    if (message[i] == '{') {
      depth++;
    } else if (message[i] == '}' && --depth == 0) {
      return message.substring(begin, i);
    }
  }
  return null;
}

void main() {
  test('the one branch of every English plural keeps its placeholder', () {
    final arb = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, dynamic>;

    final missing = arb.entries
        .where((e) => !e.key.startsWith('@') && e.value is String)
        .where((e) {
          final branch = oneBranch(e.value as String);
          return branch != null && !branch.contains(RegExp(r'\{\w+\}'));
        })
        .map((e) => e.key);

    expect(missing, isEmpty);
  });
}
