/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/widgets/core/image.dart';

class ExerciseImageWidget extends StatelessWidget {
  ExerciseImageWidget({this.image, this.height});

  final _logger = Logger('ExerciseImageWidget');
  final ExerciseImage? image;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return image != null
        ? Image.network(
            image!.url,
            semanticLabel: 'Exercise image',
            errorBuilder: (context, error, stackTrace) {
              _logger.warning('Failed to load image ${image!.url}: $error, $stackTrace');
              final imageFormat = image!.url.split('.').last.toUpperCase();

              return ImageFormatNotSupported(
                i18n.imageFormatNotSupported(imageFormat),
              );
            },
          )
        : const Image(
            image: AssetImage('assets/images/placeholder.png'),
            color: Color.fromRGBO(255, 255, 255, 0.3),
            colorBlendMode: BlendMode.modulate,
            semanticLabel: 'Placeholder',
          );
  }
}
