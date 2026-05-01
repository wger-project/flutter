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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/gallery/image.dart';
import 'package:wger/providers/gallery_notifier.dart';
import 'package:wger/providers/gallery_repository.dart';

import 'gallery_provider_test.mocks.dart';

@GenerateMocks([GalleryRepository])
void main() {
  late MockGalleryRepository mockRepo;

  final image1 = GalleryImage(
    id: 58,
    date: DateTime(2022, 01, 09),
    imagePath: 'gallery/1/1.jpg',
    description: 'image 1',
  );
  final image2 = GalleryImage(
    id: 59,
    date: DateTime(2022, 02, 14),
    imagePath: 'gallery/1/2.jpg',
    description: 'image 2',
  );

  ProviderContainer makeContainer() {
    return ProviderContainer.test(
      overrides: [galleryRepositoryProvider.overrideWithValue(mockRepo)],
    );
  }

  Future<ProviderContainer> containerWithImages(List<GalleryImage> images) async {
    when(mockRepo.watchAllDrift()).thenAnswer((_) => Stream.value(images));
    final container = makeContainer();
    container.listen(galleryProvider, (_, _) {});
    await pumpEventQueue();
    return container;
  }

  setUp(() {
    mockRepo = MockGalleryRepository();
    // Default: empty stream that never emits. Tests that exercise notifier
    // methods on a fresh container use [containerWithImages] to seed.
    when(mockRepo.watchAllDrift()).thenAnswer((_) => const Stream.empty());
    when(mockRepo.editLocalDrift(any)).thenAnswer((_) async {});
    when(mockRepo.deleteLocalDrift(any)).thenAnswer((_) async {});
  });

  test('build streams the gallery from the repository, sorted newest first', () async {
    // Drift returns rows in `Meta.ordering = ['-date']` order.
    final container = await containerWithImages([image2, image1]);

    final images = container.read(galleryProvider).value!;
    expect(images, hasLength(2));
    expect(images.first.id, 59);
    verify(mockRepo.watchAllDrift()).called(1);
  });

  test('deleteImage forwards to the repository', () async {
    final container = makeContainer();

    await container.read(galleryProvider.notifier).deleteImage(image1);

    verify(mockRepo.deleteLocalDrift(image1.id)).called(1);
  });

  test('editImage without a file routes through Drift', () async {
    final container = makeContainer();

    await container.read(galleryProvider.notifier).editImage(image1, null);

    verify(mockRepo.editLocalDrift(image1)).called(1);
    verifyNever(mockRepo.editImageServer(any, any));
  });
}
