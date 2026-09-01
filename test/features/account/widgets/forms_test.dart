/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 wger Team
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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/core/network/network_provider.dart';
import 'package:wger/features/account/models/account.dart';
import 'package:wger/features/account/models/user_profile.dart';
import 'package:wger/features/account/providers/account_repository.dart';
import 'package:wger/features/account/providers/user_profile_repository.dart';
import 'package:wger/features/account/widgets/forms.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import 'forms_test.mocks.dart';

@GenerateMocks([UserProfileRepository, AccountRepository])
void main() {
  const account = Account(
    username: 'roland',
    email: 'roland@example.com',
    emailVerified: true,
    isTrustworthy: true,
  );

  late MockUserProfileRepository profileRepo;

  /// Renders the profile form over a profile of [height] cm.
  Future<void> pump(WidgetTester tester, {int? height}) async {
    profileRepo = MockUserProfileRepository();
    when(profileRepo.watchDrift()).thenAnswer(
      (_) => Stream.value(UserProfile(id: 1, weightUnitStr: 'kg', height: height)),
    );
    when(profileRepo.editLocalDrift(any)).thenAnswer((_) async {});
    final accountRepo = MockAccountRepository();
    when(accountRepo.fetchAccount()).thenAnswer((_) async => account);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(profileRepo),
          accountRepositoryProvider.overrideWithValue(accountRepo),
          networkStatusProvider.overrideWithValue(true),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(child: UserProfileForm()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The profile the form last wrote. Reads the recorded calls once: a second
  /// verify finds nothing, mockito consumes them.
  UserProfile saved() =>
      verify(profileRepo.editLocalDrift(captureAny)).captured.last as UserProfile;

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
  }

  testWidgets('the height is prefilled from the synced profile', (tester) async {
    await pump(tester, height: 182);

    expect(find.widgetWithText(TextFormField, '182'), findsOneWidget);
  });

  testWidgets('an edited height is saved', (tester) async {
    await pump(tester, height: 182);

    await tester.enterText(find.byKey(const Key('heightField')), '178');
    await save(tester);

    expect(saved().height, 178);
  });

  testWidgets('a height is saved for a profile that had none', (tester) async {
    await pump(tester);

    await tester.enterText(find.byKey(const Key('heightField')), '182');
    await save(tester);

    expect(saved().height, 182);
  });

  testWidgets('clearing the field clears the height', (tester) async {
    // The server allows a profile without one, and nothing else does the
    // clearing: an emptied field has to reach the column as NULL
    await pump(tester, height: 182);

    await tester.enterText(find.byKey(const Key('heightField')), '');
    await save(tester);

    expect(saved().height, isNull);
  });

  testWidgets('an untouched height survives a change to the weight unit', (tester) async {
    await pump(tester, height: 182);

    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await save(tester);

    final profile = saved();
    expect(profile.weightUnitStr, 'lb');
    expect(profile.height, 182);
  });

  testWidgets('a height outside what the server takes is refused', (tester) async {
    await pump(tester, height: 182);

    await tester.enterText(find.byKey(const Key('heightField')), '250');
    await save(tester);

    expect(find.text('Please enter a value between 140 and 230'), findsOneWidget);
    verifyNever(profileRepo.editLocalDrift(any));
  });
}
