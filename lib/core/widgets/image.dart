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
  final path = Uri.tryParse(imageUrl)?.path ?? imageUrl;
  final imageFormat = path.contains('.') ? path.split('.').last.toUpperCase() : 'UNKNOWN';
  final logger = Logger('handleImageError');
  logger.warning('Failed to load image $imageUrl: $error, $stackTrace');

  // NOTE: for the moment the other error messages are not localized
  final message = switch (error) {
    NetworkImageLoadException _ => 'Network error',
    HttpException _ => 'Server connection failed',
    SocketException _ => 'No internet connection',
    //TODO: not sure if this is the right exception for unsupported image formats?
    FormatException _ => AppLocalizations.of(context).imageFormatNotSupported(imageFormat),
    _ => 'An unexpected error occurred',
  };

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
