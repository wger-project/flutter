/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
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

import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/theme/theme.dart';
import 'package:wger/widgets/dashboard/widgets/weight.dart';

import '../test/utils.dart';
import '../test/weight/weight_entries_modal_test.mocks.dart';
import '../test/weight/weight_provider_test.mocks.dart';
import '../test_data/body_weight.dart';
import '../test_data/profile.dart';

Widget createWeightScreen({Locale? locale}) {
  locale ??= const Locale('en');
  final weightProvider = BodyWeightProvider(mockBaseProvider);
  weightProvider.items = getScreenshotWeightEntries();

  final mockUserProvider = MockUserProvider();
  when(mockUserProvider.profile).thenReturn(tProfile1);

  return MediaQuery(
    data: MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).copyWith(
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    ),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (context) => mockUserProvider,
        ),
        ChangeNotifierProvider<BodyWeightProvider>(
          create: (context) => weightProvider,
        ),
      ],
      child: MaterialApp(
        locale: locale,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: wgerLightTheme,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: DashboardWeightWidget(),
          ),
        ),
      ),
    ),
  );
}
