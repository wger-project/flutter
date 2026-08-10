/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2026 - 2026 wger Team
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:wger/core/app_settings_notifier.dart';
import 'package:wger/core/consts.dart';
import 'package:wger/core/http_overrides.dart';
import 'package:wger/core/network/auth_notifier.dart';
import 'package:wger/core/network/auth_state.dart';
import 'package:wger/features/account/widgets/settings/certs_not_verified.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

import '../../../../helpers/fake_auth_notifier.dart';

void main() {
  const selfHosted = 'https://gym.example.com';

  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    WgerHttpOverrides.allowSelfSignedCerts = false;
    WgerHttpOverrides.trustedHost = null;
  });

  Future<void> pumpWidget(WidgetTester tester, {required String serverUrl}) async {
    final prefs = SharedPreferencesAsync();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsPrefsProvider.overrideWithValue(prefs),
          authProvider.overrideWith(
            () => FakeAuthNotifier(
              AuthState(status: AuthStatus.loggedIn, serverUrl: serverUrl),
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(body: SettingsCertsNotVerified()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  final warning = find.byKey(const ValueKey('certsNotVerifiedWarning'));

  testWidgets('stays hidden while certificates are verified', (tester) async {
    await pumpWidget(tester, serverUrl: selfHosted);

    expect(warning, findsNothing);
  });

  testWidgets('warns and names the host while the exemption is in effect', (tester) async {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    await SharedPreferencesAsync().setBool(PREFS_ALLOW_SELF_SIGNED_CERTS, true);
    WgerHttpOverrides.trustServer(selfHosted);

    await pumpWidget(tester, serverUrl: selfHosted);

    expect(warning, findsOneWidget);
    expect(find.textContaining('gym.example.com'), findsOneWidget);
  });

  testWidgets('stays hidden on the official server even with the opt-in stored', (tester) async {
    // The preference survives a switch back to wger.de, but the override never
    // exempts it, so warning about it would be a lie.
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    await SharedPreferencesAsync().setBool(PREFS_ALLOW_SELF_SIGNED_CERTS, true);
    WgerHttpOverrides.trustServer(DEFAULT_SERVER_PROD);

    await pumpWidget(tester, serverUrl: DEFAULT_SERVER_PROD);

    expect(warning, findsNothing);
  });
}
