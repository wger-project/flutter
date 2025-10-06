/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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

import 'dart:io';

import 'package:flutter/material.dart';

enum ImageType {
  photo(id: 1, label: 'Photo', icon: Icons.photo_camera),
  threeD(id: 2, label: '3D', icon: Icons.view_in_ar),
  line(id: 3, label: 'Line', icon: Icons.show_chart),
  lowPoly(id: 4, label: 'Low-Poly', icon: Icons.filter_vintage),
  other(id: 5, label: 'Other', icon: Icons.more_horiz);

  const ImageType({required this.id, required this.label, required this.icon});

  final int id;
  final String label;
  final IconData icon;
}

class ExerciseSubmissionImage {
  final File imageFile;

  String? title;
  String? author;
  String? authorUrl;
  String? sourceUrl;
  String? derivativeSourceUrl;
  ImageType type = ImageType.photo;

  ExerciseSubmissionImage({
    this.title,
    this.author,
    this.authorUrl,
    this.sourceUrl,
    this.derivativeSourceUrl,
    this.type = ImageType.photo,
    required this.imageFile,
  });

  Map<String, String> toJson() {
    return {
      'title': title ?? '',
      'author': author ?? '',
      'author_url': authorUrl ?? '',
      'source_url': sourceUrl ?? '',
      'derivative_source_url': derivativeSourceUrl ?? '',
      'type': type.id.toString(),
    };
  }
}
