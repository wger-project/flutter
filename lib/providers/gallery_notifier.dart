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

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/gallery/image.dart' as gallery;
import 'package:wger/providers/gallery_repository.dart';

part 'gallery_notifier.g.dart';

@Riverpod(keepAlive: true)
class GalleryNotifier extends _$GalleryNotifier {
  late GalleryRepository _repo;

  @override
  Future<List<gallery.Image>> build() async {
    _repo = ref.read(galleryRepositoryProvider);
    return _repo.fetchAll();
  }

  List<gallery.Image> get _current => state.asData?.value ?? [];

  /// Re-fetches the gallery from the server (used by pull-to-refresh).
  Future<void> refresh() async {
    state = AsyncData(await _repo.fetchAll());
  }

  Future<void> addImage(gallery.Image image, XFile imageFile) async {
    final saved = await _repo.addImage(image, imageFile);
    final images = List<gallery.Image>.of(_current)..add(saved);
    images.sort((a, b) => b.date.compareTo(a.date));
    state = AsyncData(images);
  }

  Future<void> editImage(gallery.Image image, XFile? imageFile) async {
    final updatedUrl = await _repo.editImage(image, imageFile);
    if (updatedUrl != null) {
      image.url = updatedUrl;
    }
    // [image] is a shared reference held by the list, so the update is already
    // visible — just notify listeners.
    state = AsyncData(List.of(_current));
  }

  Future<void> deleteImage(gallery.Image image) async {
    await _repo.deleteImage(image.id!);
    state = AsyncData(_current.where((e) => e.id != image.id).toList());
  }

  /// Clears the gallery (e.g. on logout).
  void clear() {
    state = const AsyncData([]);
  }
}
