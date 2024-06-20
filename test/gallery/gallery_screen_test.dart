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
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/screens/form_screen.dart';
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

  Widget createScreen({locale = 'en'}) {
    return ChangeNotifierProvider<GalleryProvider>(
      create: (context) => mockGalleryProvider,
      child: MaterialApp(
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Gallery(),
        routes: {
          FormScreen.routeName: (ctx) => const FormScreen(),
        },
      ),
    );
  }

  testWidgets('Test the widgets on the gallery screen', (WidgetTester tester) async {
    await mockNetworkImagesFor(() => tester.pumpWidget(createScreen()));

    expect(find.byType(SliverMasonryGrid), findsOneWidget);
    expect(find.byType(GestureDetector, skipOffstage: false), findsNWidgets(4));
  });

  testWidgets('Test opening the form for an existing image', (WidgetTester tester) async {
    await mockNetworkImagesFor(() => tester.pumpWidget(createScreen()));

    await tester.tap(find.byKey(const Key('image-1')));
    await tester.pumpAndSettle();

    // Detail dialog opens
    expect(find.byKey(const Key('image-1-detail')), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(5)); // four in the overview, one in the popup
    expect(find.text('A very cool image from the gym'), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);

    // Edit form opens
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.text('A very cool image from the gym'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - EN', (WidgetTester tester) async {
    await mockNetworkImagesFor(() => tester.pumpWidget(createScreen()));
    await tester.tap(find.byKey(const Key('image-1')));
    await tester.pumpAndSettle();

    expect(find.text('5/30/2021'), findsOneWidget);
  });

  testWidgets('Tests the localization of dates - DE', (WidgetTester tester) async {
    await mockNetworkImagesFor(() => tester.pumpWidget(createScreen(locale: 'de')));
    await tester.tap(find.byKey(const Key('image-1')));
    await tester.pumpAndSettle();

    expect(find.text('30.5.2021'), findsOneWidget);
  });
}
