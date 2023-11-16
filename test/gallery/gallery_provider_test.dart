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

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:wger/models/gallery/image.dart' as gallery;
import 'package:wger/providers/gallery.dart';

import '../other/base_provider_test.mocks.dart';
import '../utils.dart';

void main() {
  group('test gallery provider', () {
    test('Test that fetch and set gallery', () async {
      final client = MockClient();

      when(client.get(
        Uri.https('localhost', 'api/v2/gallery/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
          '{"count":1,"next":null,"previous":null,"results":['
          '{"id":58,'
          '"date":"2022-01-09",'
          '"image":"https://wger.de/media/gallery/170335/d2b9c9e0-d541-41ae-8786-a2ab459e3538.jpg",'
          '"description":"eggsaddjujuit\'ddayhadIforcanview",'
          '"height":1280,"width":960}]}',
          200));

      final galleryProvider = GalleryProvider(testAuthProvider, [], client);

      await galleryProvider.fetchAndSetGallery();

      // Check that everything is ok
      expect(galleryProvider.images.length, 1);
    });

    test('Test that delete gallery photo', () async {
      final client = MockClient();

      when(client.delete(
        Uri.https('localhost', 'api/v2/gallery/58/'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
          '{"id":58,'
          '"date":"2022-01-09",'
          '"image":"https://wger.de/media/gallery/170335/d2b9c9e0-d541-41ae-8786-a2ab459e3538.jpg",'
          '"description":"eggsaddjujuit\'ddayhadIforcanview",'
          '"height":1280,"width":960}',
          200));

      final galleryProvider = GalleryProvider(testAuthProvider, [], client);

      final image = gallery.Image(
          id: 58,
          date: DateTime(2022, 01, 09),
          url: 'https://wger.de/media/gallery/170335/d2b9c9e0-d541-41ae-8786-a2ab459e3538.jpg',
          description: "eggsaddjujuit'ddayhadIforcanview");

      galleryProvider.images.add(image);

      await galleryProvider.deleteImage(image);

      // Check that everything is ok
      expect(galleryProvider.images.length, 0);
    });
  });
}
