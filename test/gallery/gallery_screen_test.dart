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
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/widgets/gallery/overview.dart';

import '../../test_data/gallery.dart';
import './gallery_screen_test.mocks.dart';

@GenerateMocks([GalleryProvider])
void main() {
  var mockGalleryProvider = MockGalleryProvider();

  setUp(() {
    mockGalleryProvider = MockGalleryProvider();
    when(mockGalleryProvider.images).thenAnswer((_) => getTestImages());
  });

  Widget renderScreen({locale = 'en'}) {
    return ChangeNotifierProvider<GalleryProvider>(
      create: (context) => mockGalleryProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Gallery(),
      ),
    );
  }

  Widget renderDetail({locale = 'en'}) {
    return ChangeNotifierProvider<GalleryProvider>(
      create: (context) => mockGalleryProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ImageDetail(image: getTestImages()[0]),
      ),
    );
  }

  testWidgets('Test the widgets on the gallery screen', (WidgetTester tester) async {
    await mockNetworkImagesFor(() => tester.pumpWidget(renderScreen()));

    expect(find.byType(SliverMasonryGrid), findsOneWidget);
    expect(find.byType(GestureDetector, skipOffstage: false), findsNWidgets(4));
  });

  testWidgets('Tests the localization of dates - EN', (WidgetTester tester) async {
    await mockNetworkImagesFor(() => tester.pumpWidget(renderDetail()));
    await tester.pumpAndSettle();

    expect(find.text('5/30/2021'), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - DE', (WidgetTester tester) async {
    await mockNetworkImagesFor(() => tester.pumpWidget(renderDetail(locale: 'de')));
    await tester.pumpAndSettle();

    expect(find.text('30.5.2021'), findsOneWidget);
  });
}
