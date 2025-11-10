import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

Widget handleImageError(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
  String imageUrl,
) {
  final imageFormat = imageUrl.split('.').last.toUpperCase();
  final logger = Logger('handleImageError');
  logger.warning('Failed to load image $imageUrl: $error, $stackTrace');

  // NOTE: for the moment the other error messages are not localized
  String message = '';
  switch (error.runtimeType) {
    case NetworkImageLoadException:
      message = 'Network error';
    case HttpException:
      message = 'Http error';
    case FormatException:
      //TODO: not sure if this is the right exception for unsupported image formats?
      message = AppLocalizations.of(context).imageFormatNotSupported(imageFormat);
    default:
      message = 'Other exception';
  }

  return AspectRatio(
    aspectRatio: 1,
    child: ImageError(
      message,
      errorMessage: error.toString(),
    ),
  );
}

class ImageError extends StatelessWidget {
  final String title;
  final String? errorMessage;

  const ImageError(this.title, {this.errorMessage, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(5),
      color: theme.colorScheme.errorContainer,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          if (errorMessage != null)
            Tooltip(message: errorMessage, child: const Icon(Icons.broken_image))
          else
            const Icon(Icons.broken_image),

          Text(
            title,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
