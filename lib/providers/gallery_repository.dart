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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/gallery/image.dart' as gallery;
import 'package:wger/providers/base_provider.dart';
import 'package:wger/providers/wger_base.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  final base = ref.read(wgerBaseProvider);
  return GalleryRepository(base);
});

/// HTTP-only data access for the user's gallery.
class GalleryRepository {
  static const _galleryUrlPath = 'gallery';

  final _logger = Logger('GalleryRepository');
  final WgerBaseProvider _base;

  GalleryRepository(this._base);

  /// Fetches all gallery images, sorted newest first.
  Future<List<gallery.Image>> fetchAll() async {
    _logger.fine('Fetching gallery');
    final data = await _base.fetch(_base.makeUrl(_galleryUrlPath));
    final images = (data['results'] as List)
        .map((e) => gallery.Image.fromJson(e as Map<String, dynamic>))
        .toList();
    images.sort((a, b) => b.date.compareTo(a.date));
    return images;
  }

  /// Uploads a new image with metadata. Returns the saved image.
  Future<gallery.Image> addImage(gallery.Image image, XFile imageFile) async {
    final request = http.MultipartRequest('POST', _base.makeUrl(_galleryUrlPath))
      ..headers.addAll(_base.getDefaultHeaders(includeAuth: true))
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path))
      ..fields['date'] = dateToYYYYMMDD(image.date)!
      ..fields['description'] = image.description;

    final res = await request.send();
    final respStr = await res.stream.bytesToString();
    return gallery.Image.fromJson(json.decode(respStr));
  }

  /// Edits an existing image. [imageFile] is optional — only sent if
  /// the user picked a new one.
  Future<String?> editImage(gallery.Image image, XFile? imageFile) async {
    final request = http.MultipartRequest('PATCH', _base.makeUrl(_galleryUrlPath, id: image.id))
      ..headers.addAll(_base.getDefaultHeaders(includeAuth: true));

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final data = image.toJson();
    request.fields['id'] = data['id'].toString();
    request.fields['date'] = data['date'];
    request.fields['description'] = data['description'];

    final res = await request.send();
    final respStr = await res.stream.bytesToString();
    final responseData = json.decode(respStr);
    return responseData['image'] as String?;
  }

  Future<void> deleteImage(int id) async {
    await _base.deleteRequest(_galleryUrlPath, id);
  }
}
