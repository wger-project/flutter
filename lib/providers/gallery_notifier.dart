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
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wger/models/gallery/image.dart';
import 'package:wger/providers/gallery_repository.dart';

part 'gallery_notifier.g.dart';

@Riverpod(keepAlive: true)
class GalleryNotifier extends _$GalleryNotifier {
  final _logger = Logger('GalleryNotifier');
  late GalleryRepository _repo;

  @override
  Stream<List<GalleryImage>> build() {
    _logger.finer('Building GalleryNotifier');
    _repo = ref.read(galleryRepositoryProvider);
    return _repo.watchAllDrift();
  }

  List<GalleryImage> get _current => state.value ?? const [];

  /// Adds a new image. Goes through REST because PowerSync can't carry the
  /// binary upload, then optimistically inserts the saved row into local
  /// state so the UI updates without waiting for the next sync tick. The
  /// stream's next emission carries the synced row through and replaces the
  /// optimistic copy.
  Future<void> addImage(GalleryImage image, XFile imageFile) async {
    final saved = await _repo.addImageServer(image, imageFile);
    final updated = [saved, ..._current]..sort((a, b) => b.date.compareTo(a.date));
    state = AsyncData(updated);
  }

  /// Edits an image. With a new [imageFile], the change goes through REST
  /// (file upload). Without one, only metadata changed and the edit goes
  /// through PowerSync (Drift update → CRUD queue → backend); the stream
  /// picks up the change on the next tick.
  Future<void> editImage(GalleryImage image, XFile? imageFile) async {
    if (imageFile != null) {
      final newPath = await _repo.editImageServer(image, imageFile);
      if (newPath != null) {
        image.imagePath = newPath;
      }
      // [image] is a shared reference held by the synced list — the path
      // mutation above is visible immediately. Notify listeners so widgets
      // pick up the new image bytes.
      state = AsyncData(List.of(_current));
    } else {
      await _repo.editLocalDrift(image);
    }
  }

  /// Deletes an image. Goes through PowerSync (Drift delete → CRUD queue →
  /// backend), where the model's `post_delete` signal also removes the
  /// underlying file from storage.
  Future<void> deleteImage(GalleryImage image) async {
    await _repo.deleteLocalDrift(image.id!);
  }
}
