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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/gallery/image.dart' as gallery;
import 'package:wger/providers/gallery_notifier.dart';
import 'package:wger/providers/gallery_repository.dart';

import 'gallery_provider_test.mocks.dart';

@GenerateMocks([GalleryRepository])
void main() {
  late MockGalleryRepository mockRepo;
  late ProviderContainer container;

  final image1 = gallery.Image(
    id: 58,
    date: DateTime(2022, 01, 09),
    url: 'https://example.com/1.jpg',
    description: 'image 1',
  );
  final image2 = gallery.Image(
    id: 59,
    date: DateTime(2022, 02, 14),
    url: 'https://example.com/2.jpg',
    description: 'image 2',
  );

  setUp(() {
    mockRepo = MockGalleryRepository();
    when(mockRepo.fetchAll()).thenAnswer((_) async => [image2, image1]);

    container = ProviderContainer(
      overrides: [galleryRepositoryProvider.overrideWithValue(mockRepo)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('build fetches the gallery from the repository', () async {
    final images = await container.read(galleryProvider.future);

    expect(images, hasLength(2));
    expect(images.first.id, 59); // sorted newest first
    verify(mockRepo.fetchAll()).called(1);
  });

  test('deleteImage removes the image from state', () async {
    await container.read(galleryProvider.future);
    when(mockRepo.deleteImage(any)).thenAnswer((_) async {});

    await container.read(galleryProvider.notifier).deleteImage(image1);

    final images = container.read(galleryProvider).value!;
    expect(images.map((e) => e.id), [image2.id]);
    verify(mockRepo.deleteImage(image1.id!)).called(1);
  });

  test('clear() resets the state to an empty list', () async {
    await container.read(galleryProvider.future);
    expect(container.read(galleryProvider).value, hasLength(2));

    container.read(galleryProvider.notifier).clear();
    expect(container.read(galleryProvider).value, isEmpty);
  });
}
