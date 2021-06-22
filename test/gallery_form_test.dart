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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/gallery/image.dart' as gallery;
import 'package:wger/providers/gallery.dart';
import 'package:wger/widgets/gallery/forms.dart';

import '../test_data/gallery.dart';
import 'gallery_screen_test.mocks.dart';

void main() {
  late gallery.Image image;
  var mockGalleryProvider = MockGalleryProvider();

  setUp(() {
    image = getTestImages()[0];
  });

  Widget createScreen({useImage = true, locale = 'en'}) {
    return ChangeNotifierProvider<GalleryProvider>(
      create: (context) => mockGalleryProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: useImage ? ImageForm(image) : ImageForm(),
        ),
      ),
    );
  }

  testWidgets('Test opening the form for an existing image', (WidgetTester tester) async {
    await mockNetworkImagesFor(() => tester.pumpWidget(createScreen(useImage: true)));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2)); // four in the overview, one in the popup
    expect(find.text('A very cool image from the gym'), findsOneWidget);
    expect(find.byKey(Key(SUBMIT_BUTTON_KEY_NAME)), findsOneWidget);

    await tester.enterText(find.byKey(Key('field-date')), '2021-06-01');
    await tester.tap(find.byKey(Key(SUBMIT_BUTTON_KEY_NAME)));

    verifyNever(mockGalleryProvider.addImage(any, any));
    verify(mockGalleryProvider.editImage(any, any));
  });

  testWidgets('Test opening the form for a new image', (WidgetTester tester) async {
    await mockNetworkImagesFor(() => tester.pumpWidget(createScreen(useImage: false)));
    await tester.pumpAndSettle();

    expect(find.text('Please select an image'), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera), findsOneWidget);
  });
}
