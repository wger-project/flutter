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

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:wger/core/exceptions/http_exception.dart';
import 'package:wger/database/powersync/database.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/gallery/image.dart';
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/wger_base.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  final base = ref.read(wgerBaseProvider);
  final db = ref.read(driftPowerSyncDatabase);
  return GalleryRepository(base, db);
});

/// Data access for gallery images.
///
/// REST handles anything that involves the binary file (create, edit-with-
/// new-file). Reads, metadata edits and deletes go through the local
/// PowerSync-backed Drift table — see [watchAllDrift], [editLocalDrift]
/// and [deleteLocalDrift].
class GalleryRepository {
  static const _galleryUrlPath = 'gallery';

  final _logger = Logger('GalleryRepository');
  final WgerBaseProvider _base;
  final DriftPowersyncDatabase _db;

  GalleryRepository(this._base, this._db);

  /// Streams all gallery images, sorted newest first to match Django's
  /// `Image.Meta.ordering = ['-date']`.
  Stream<List<GalleryImage>> watchAllDrift() {
    _logger.finer('Watching all local gallery images');
    return (_db.select(
      _db.galleryImageTable,
    )..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])).watch();
  }

  /// Uploads a new image with metadata via REST. Returns the saved row.
  Future<GalleryImage> addImageServer(GalleryImage image, XFile imageFile) async {
    final request = http.MultipartRequest('POST', _base.makeUrl(_galleryUrlPath))
      ..headers.addAll(_base.getDefaultHeaders(includeAuth: true))
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path))
      ..fields['date'] = dateToYYYYMMDD(image.date)!
      ..fields['description'] = image.description;

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode >= 400) {
      throw WgerHttpException(response);
    }
    return GalleryImage.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  /// PATCHes an image whose binary file has changed. Returns the new
  /// relative storage path so the caller can reflect it in local state
  /// before the next PowerSync emission catches up.
  Future<String?> editImageServer(GalleryImage image, XFile imageFile) async {
    final request = http.MultipartRequest('PATCH', _base.makeUrl(_galleryUrlPath, id: image.id))
      ..headers.addAll(_base.getDefaultHeaders(includeAuth: true))
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path))
      ..fields['date'] = dateToYYYYMMDD(image.date)!
      ..fields['description'] = image.description;

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode >= 400) {
      throw WgerHttpException(response);
    }
    final responseData = json.decode(response.body);
    return responseData['image'] as String?;
  }

  /// Updates an image's metadata via the local Drift table. The PowerSync
  /// CRUD queue propagates the change to the backend.
  Future<void> editLocalDrift(GalleryImage image) async {
    final id = image.id;
    if (id == null) {
      throw StateError('Cannot edit a gallery image without id');
    }
    _logger.finer('Updating local gallery image $id');
    await (_db.update(
      _db.galleryImageTable,
    )..where((t) => t.id.equals(id))).write(image.toCompanion());
  }

  /// Deletes a gallery image via the local Drift table. PowerSync syncs
  /// the delete to the backend, where Django's `post_delete` signal also
  /// removes the underlying file from storage.
  Future<void> deleteLocalDrift(int id) async {
    _logger.finer('Deleting local gallery image $id');
    await (_db.delete(_db.galleryImageTable)..where((t) => t.id.equals(id))).go();
  }
}
