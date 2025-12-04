/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020, 2025 wger Team
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

import 'dart:math';
import 'dart:typed_data';

String uuidV4() {
  final rnd = Random.secure();
  final bytes = Uint8List(16);
  for (var i = 0; i < 16; i++) {
    bytes[i] = rnd.nextInt(256);
  }

  // Set version to 4 -> xxxx0100
  bytes[6] = (bytes[6] & 0x0F) | 0x40;

  // Set variant to RFC4122 -> 10xxxxxx
  bytes[8] = (bytes[8] & 0x3F) | 0x80;

  return _bytesToUuid(bytes);
}

String _bytesToUuid(Uint8List bytes) {
  final sb = StringBuffer();
  for (var i = 0; i < bytes.length; i++) {
    sb.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    if (i == 3 || i == 5 || i == 7 || i == 9) sb.write('-');
  }
  return sb.toString();
}
