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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wger/core/error_dialogs.dart';
import 'package:wger/helpers/errors.dart';

void main() {
  group('formatApiErrors', () {
    final errors = [
      ApiError(key: 'username', errorMessages: ['too short', 'already taken']),
    ];

    test('leaves the text color unset so it inherits the theme (dark-mode readable)', () {
      // Hardcoding a color (the old Colors.black default) made the API error
      // dialog unreadable on a dark background. A null color inherits instead.
      final texts = formatApiErrors(errors).whereType<Text>().toList();

      expect(texts, isNotEmpty);
      expect(texts.every((t) => t.style?.color == null), isTrue);
    });

    test('applies an explicit color when one is given', () {
      final texts = formatApiErrors(errors, color: Colors.red).whereType<Text>().toList();

      expect(texts, isNotEmpty);
      expect(texts.every((t) => t.style?.color == Colors.red), isTrue);
    });
  });
}
