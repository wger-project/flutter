import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/measurement.dart';
import 'package:wger/screens/measurement_categories_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/measurements/measurement_categories_screen_test.mocks.dart';
import '../test_data/measurements.dart';

Widget createMeasurementScreen({locale = 'en'}) {
  final mockMeasurementProvider = MockMeasurementProvider();
  when(mockMeasurementProvider.categories).thenReturn(getMeasurementCategories());

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<MeasurementProvider>(
        create: (context) => mockMeasurementProvider,
      ),
    ],
    child: MaterialApp(
      locale: Locale(locale),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: wgerLightTheme,
      home: const MeasurementCategoriesScreen(),
    ),
  );
}
