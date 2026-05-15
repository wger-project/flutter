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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wger/models/user/account.dart';
import 'package:wger/providers/account_notifier.dart';
import 'package:wger/providers/account_repository.dart';

import 'account_notifier_test.mocks.dart';

@GenerateMocks([AccountRepository])
void main() {
  late MockAccountRepository mockRepo;

  const tAccount = Account(
    username: 'admin',
    email: 'me@example.com',
    emailVerified: true,
    isTrustworthy: true,
  );

  setUp(() {
    mockRepo = MockAccountRepository();
    when(mockRepo.fetchAccount()).thenAnswer((_) async => tAccount);
  });

  ProviderContainer makeContainer() => ProviderContainer.test(
    overrides: [accountRepositoryProvider.overrideWithValue(mockRepo)],
  );

  test('build fetches the account from the repository', () async {
    final container = makeContainer();

    final account = await container.read(accountProvider.future);

    expect(account, isNotNull);
    expect(account!.username, 'admin');
    expect(account.isTrustworthy, true);
    verify(mockRepo.fetchAccount()).called(1);
  });

  test('clear() resets the account to null', () async {
    final container = makeContainer();
    await container.read(accountProvider.future);
    expect(container.read(accountProvider).value, isNotNull);

    container.read(accountProvider.notifier).clear();

    expect(container.read(accountProvider).value, isNull);
  });

  test('requestEmailChange delegates to the repository', () async {
    final container = makeContainer();
    await container.read(accountProvider.future);
    when(mockRepo.requestEmailChange(any)).thenAnswer((_) async {});

    await container.read(accountProvider.notifier).requestEmailChange('new@example.com');

    verify(mockRepo.requestEmailChange('new@example.com')).called(1);
  });

  test('resendVerification delegates to the repository', () async {
    final container = makeContainer();
    await container.read(accountProvider.future);
    when(mockRepo.resendVerification(any)).thenAnswer((_) async {});

    await container.read(accountProvider.notifier).resendVerification('me@example.com');

    verify(mockRepo.resendVerification('me@example.com')).called(1);
  });
}
