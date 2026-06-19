/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020 - 2026 wger Team
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

import 'package:drift/drift.dart' as drift;
import 'package:json_annotation/json_annotation.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/helpers/json.dart';

part 'image.g.dart';

/// A single picture in the user's gallery.
///
/// [imagePath] holds the relative storage path (Django `ImageField`'s column
/// value, e.g. `gallery/1/abc.jpg`); resolve it via `mediaUrlBuilderProvider`
/// or render with `WgerImage(mediaPath: ...)`. JSON support is kept so the
/// REST POST response (which still handles uploads) hydrates cleanly.
@JsonSerializable()
class GalleryImage {
  // Mirrors the backend description max_length (server gallery/models/image.py).
  static const MAX_LENGTH_DESCRIPTION = 1000;

  @JsonKey(required: true)
  int? id;

  @JsonKey(required: true, fromJson: utcIso8601ToLocalDate, toJson: dateToUtcIso8601)
  late DateTime date;

  @JsonKey(name: 'image')
  String? imagePath;

  @JsonKey(defaultValue: '')
  late String description;

  GalleryImage({
    this.id,
    DateTime? date,
    this.imagePath,
    String? description,
  }) {
    this.date = date ?? DateTime.now();
    this.description = description ?? '';
  }

  /// Convenience for the form's "new image" path: an empty entry to be
  /// filled in by the user before upload.
  GalleryImage.empty() {
    date = DateTime.now();
    description = '';
  }

  // Boilerplate
  factory GalleryImage.fromJson(Map<String, dynamic> json) => _$GalleryImageFromJson(json);

  Map<String, dynamic> toJson() => _$GalleryImageToJson(this);

  /// Drift companion used for local UPDATE writes routed through PowerSync.
  ///
  /// Throws if [id] is null, creation goes through REST (file upload), so
  /// rows without a server-assigned id should never be written locally.
  /// The `image` column is intentionally omitted: file-changing edits also
  /// go through REST and metadata-only edits leave the path untouched.
  GalleryImageTableCompanion toCompanion() {
    final imageId = id;
    if (imageId == null) {
      throw StateError('Cannot persist gallery image without id (creation goes via REST)');
    }
    return GalleryImageTableCompanion(
      id: drift.Value(imageId),
      date: drift.Value(DateTime.utc(date.year, date.month, date.day)),
      description: drift.Value(description),
    );
  }
}
