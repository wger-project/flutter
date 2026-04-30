/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/providers/wger_base.dart';
import 'package:wger/widgets/core/image.dart';
import 'package:wger/widgets/core/progress_indicator.dart';

/// Displays a server-hosted image with disk + memory caching.
///
/// [mediaPath] is whatever the server stores in a Django `ImageField`
/// (e.g. `ingredients/42/foo.jpg`) or, transparently, an already
/// absolute URL. If [mediaPath] is null, empty, or the user is not logged in,
/// the [errorWidget] (or a default broken-image icon) is shown.
///
/// [cacheWidth] / [cacheHeight] are passed to the underlying decoder
/// so the cached bytes are scaled to display size — use this for
/// avatars and thumbnails to avoid keeping multi-megapixel originals
/// in the cache. Both are pixel values, not logical pixels.
///
class WgerImage extends ConsumerWidget {
  /// Relative DB path or absolute URL. Null/empty renders [errorWidget].
  final String? mediaPath;

  final double? width;
  final double? height;
  final BoxFit fit;

  /// Pixel-size hint for the decoder.
  final int? cacheWidth;
  final int? cacheHeight;

  /// Shown while loading. Defaults to a centred [CircularProgressIndicator].
  final Widget? placeholder;

  /// Shown on load failure or when [mediaPath] cannot be resolved.
  /// Defaults to an [Icons.broken_image].
  final Widget? errorWidget;

  /// Optional rounded clipping. For circular avatars prefer wrapping in
  /// [CircleAvatar] at the call site.
  final BorderRadius? borderRadius;

  const WgerImage({
    super.key,
    required this.mediaPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.cacheHeight,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(mediaUrlBuilderProvider)(mediaPath);
    if (url == null) {
      return _wrapClip(_sized(errorWidget ?? const ImageError('')));
    }

    final image = ExtendedImage.network(
      url.toString(),
      width: width,
      height: height,
      fit: fit,
      cache: true,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      handleLoadingProgress: true,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return _sized(placeholder ?? const CenteredProgressIndicator());
          case LoadState.failed:
            return _sized(
              errorWidget ??
                  ImageError(
                    'Network error',
                    errorMessage: state.lastException?.toString(),
                  ),
            );
          case LoadState.completed:
            // Returning null lets ExtendedImage render the loaded image.
            return null;
        }
      },
    );

    return _wrapClip(image);
  }

  Widget _wrapClip(Widget child) {
    if (borderRadius == null) {
      return child;
    }
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  /// Constrains the placeholder/error widget to the same box as the image
  /// would occupy, so layouts don't jump between states. Pass-through if
  /// the caller didn't specify a size.
  Widget _sized(Widget child) {
    if (width == null && height == null) {
      return child;
    }
    return SizedBox(width: width, height: height, child: child);
  }
}
