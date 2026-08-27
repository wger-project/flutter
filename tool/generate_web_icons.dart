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

/// Regenerates the PWA icons and the favicon under web/ from the wger logo.
/// Run with:
///   dart run tool/generate_web_icons.dart
library;

import 'dart:io';

import 'package:image/image.dart';

const _source = 'assets/images/logo-512.png';
const _iconDir = 'web/icons';
const _favicon = 'web/favicon.png';

const _sizes = [192, 512];
const _faviconSize = 32;

/// The brand blue the logo hexagon is filled with, so the hexagon blends into
/// the background and the result matches the Android launcher icon.
final _background = ColorRgb8(0x2a, 0x4c, 0x7d);

/// Maskable icons get cropped to a launcher-chosen shape; only the centred
/// circle of 80% diameter is guaranteed to stay visible. Shrink the artwork so
/// the dumbbell clears that circle with a margin rather than touching it.
const _maskableScale = 0.82;

void main() {
  final source = decodePng(File(_source).readAsBytesSync());
  if (source == null) {
    stderr.writeln('Could not decode $_source');
    exit(1);
  }

  // The logo is transparent outside the hexagon, so flatten it onto the brand
  // colour first: everything below works on an opaque, full-bleed icon.
  final flattened = _onBackground(source.width, source.height);
  compositeImage(flattened, source);

  for (final size in _sizes) {
    _write('$_iconDir/Icon-$size.png', copyResize(flattened, width: size, height: size));

    final artwork = (size * _maskableScale).round();
    final maskable = _onBackground(size, size);
    final offset = ((size - artwork) / 2).round();
    compositeImage(
      maskable,
      copyResize(flattened, width: artwork, height: artwork),
      dstX: offset,
      dstY: offset,
    );
    _write('$_iconDir/Icon-maskable-$size.png', maskable);
  }

  _write(_favicon, copyResize(flattened, width: _faviconSize, height: _faviconSize));
}

/// An opaque [width] x [height] canvas filled with the brand colour. Alpha is
/// dropped because the icons are always composited on their own background.
Image _onBackground(int width, int height) =>
    Image(width: width, height: height, numChannels: 3)..clear(_background);

void _write(String path, Image image) {
  File(path).writeAsBytesSync(encodePng(image));
  stdout.writeln('wrote $path (${image.width}x${image.height})');
}
