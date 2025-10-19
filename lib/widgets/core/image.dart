import 'package:flutter/material.dart';

class ImageFormatNotSupported extends StatelessWidget {
  final String title;

  const ImageFormatNotSupported(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.errorContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [const Icon(Icons.broken_image), Text(title)],
      ),
    );
  }
}
