/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2025 wger Team
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trophies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trophies)
const trophiesProvider = TrophiesProvider._();

final class TrophiesProvider
    extends $FunctionalProvider<AsyncValue<List<Trophy>>, List<Trophy>, FutureOr<List<Trophy>>>
    with $FutureModifier<List<Trophy>>, $FutureProvider<List<Trophy>> {
  const TrophiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trophiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trophiesHash();

  @$internal
  @override
  $FutureProviderElement<List<Trophy>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Trophy>> create(Ref ref) {
    return trophies(ref);
  }
}

String _$trophiesHash() => r'44dd5e9a820f4e37599daac2a49a9358386758a8';

@ProviderFor(trophyProgression)
const trophyProgressionProvider = TrophyProgressionProvider._();

final class TrophyProgressionProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserTrophyProgression>>,
          List<UserTrophyProgression>,
          FutureOr<List<UserTrophyProgression>>
        >
    with
        $FutureModifier<List<UserTrophyProgression>>,
        $FutureProvider<List<UserTrophyProgression>> {
  const TrophyProgressionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trophyProgressionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trophyProgressionHash();

  @$internal
  @override
  $FutureProviderElement<List<UserTrophyProgression>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserTrophyProgression>> create(Ref ref) {
    return trophyProgression(ref);
  }
}

String _$trophyProgressionHash() => r'444caf04f3d0a7845e840d452e4b4a822b59df9b';
