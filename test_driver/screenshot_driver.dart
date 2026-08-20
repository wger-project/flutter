/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test_driver_extended.dart';

// cf. https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k
Future<void> main() async {
  try {
    await integrationDriver(
      onScreenshot: (String screenshotName, List<int> screenshotBytes, [_]) async {
        final File image = await File(screenshotName).create(recursive: true);
        image.writeAsBytesSync(_withoutAlpha(screenshotBytes));
        return true;
      },
    );
  } catch (e) {
    print('An error occurred: $e');
  }
}

/// Re-encodes a PNG as opaque 8 bit RGB
///
/// The App Store rejects screenshots with an alpha channel. Returns the
/// input unchanged if it can't be decoded.
List<int> _withoutAlpha(List<int> bytes) {
  final decoded = img.decodePng(Uint8List.fromList(bytes));
  if (decoded == null) {
    print('Could not decode the screenshot, writing it out unchanged');
    return bytes;
  }

  return img.encodePng(decoded.convert(format: img.Format.uint8, numChannels: 3));
}
