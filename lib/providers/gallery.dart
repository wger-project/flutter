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

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/models/gallery/image.dart' as gallery;
import 'package:wger/providers/base_provider.dart';

class GalleryProvider extends WgerBaseProvider with ChangeNotifier {
  static const _galleryUrlPath = 'gallery';

  List<gallery.Image> images = [];

  GalleryProvider(super.auth, List<gallery.Image> entries, [super.client]) : images = entries;

  /// Clears all lists
  void clear() {
    images = [];
  }

  /*
   * Gallery
   */
  Future<void> fetchAndSetGallery() async {
    final data = await fetch(makeUrl(_galleryUrlPath));

    images = [];
    data['results'].forEach((e) {
      final gallery.Image image = gallery.Image.fromJson(e);
      images.add(image);
    });

    notifyListeners();
  }

  Future<void> addImage(gallery.Image image, XFile imageFile) async {
    // create multipart request
    final request = http.MultipartRequest('POST', makeUrl(_galleryUrlPath));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: 'Token ${auth.token}',
      HttpHeaders.userAgentHeader: auth.getAppNameHeader(),
    });
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.fields['date'] = toDate(image.date)!;
    request.fields['description'] = image.description;

    final res = await request.send();
    final respStr = await res.stream.bytesToString();

    images.add(gallery.Image.fromJson(json.decode(respStr)));
    images.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
  }

  Future<void> editImage(gallery.Image image, XFile? imageFile) async {
    final request = http.MultipartRequest('PATCH', makeUrl(_galleryUrlPath, id: image.id));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: 'Token ${auth.token}',
      HttpHeaders.userAgentHeader: auth.getAppNameHeader(),
    });

    // Only send the image if a new one was selected
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    // Update image info
    final data = image.toJson();
    request.fields['id'] = data['id'].toString();
    request.fields['date'] = data['date'];
    request.fields['description'] = data['description'];

    final res = await request.send();
    final respStr = await res.stream.bytesToString();
    final responseData = json.decode(respStr);
    image.url = responseData['image'];

    notifyListeners();
  }

  Future<void> deleteImage(gallery.Image image) async {
    final response = await deleteRequest(_galleryUrlPath, image.id!);
    images.removeWhere((element) => element.id == image.id);

    notifyListeners();
  }
}
