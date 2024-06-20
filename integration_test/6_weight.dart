import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/screens/form_screen.dart';
import 'package:wger/screens/weight_screen.dart';
import 'package:wger/theme/theme.dart';

import '../test/utils.dart';
import '../test/weight/weight_screen_test.mocks.dart';
import '../test_data/body_weight.dart';
import '../test_data/profile.dart';

Widget createWeightScreen({locale = 'en'}) {
  final mockWeightProvider = BodyWeightProvider(mockBaseProvider);
  mockWeightProvider.items = getScreenshotWeightEntries();

  final mockUserProvider = MockUserProvider();
  when(mockUserProvider.profile).thenReturn(tProfile1);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(
        create: (context) => mockUserProvider,
      ),
      ChangeNotifierProvider<BodyWeightProvider>(
        create: (context) => mockWeightProvider,
      ),
    ],
    child: MaterialApp(
      locale: Locale(locale),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: wgerLightTheme,
      home: const WeightScreen(),
      routes: {
        FormScreen.routeName: (ctx) => const FormScreen(),
      },
    ),
  );
}
