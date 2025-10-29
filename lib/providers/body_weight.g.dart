/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c) 2020,  wger Team
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

part of 'body_weight.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WeightEntryNotifier)
const weightEntryProvider = WeightEntryNotifierFamily._();

final class WeightEntryNotifierProvider
    extends $StreamNotifierProvider<WeightEntryNotifier, List<WeightEntry>> {
  const WeightEntryNotifierProvider._({
    required WeightEntryNotifierFamily super.from,
    required BodyWeightRepository? super.argument,
  }) : super(
         retry: null,
         name: r'weightEntryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weightEntryNotifierHash();

  @override
  String toString() {
    return r'weightEntryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WeightEntryNotifier create() => WeightEntryNotifier();

  @override
  bool operator ==(Object other) {
    return other is WeightEntryNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weightEntryNotifierHash() => r'4f3c19bc827ca6f702f17fb0399b431c6209a47a';

final class WeightEntryNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          WeightEntryNotifier,
          AsyncValue<List<WeightEntry>>,
          List<WeightEntry>,
          Stream<List<WeightEntry>>,
          BodyWeightRepository?
        > {
  const WeightEntryNotifierFamily._()
    : super(
        retry: null,
        name: r'weightEntryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WeightEntryNotifierProvider call([BodyWeightRepository? repository]) =>
      WeightEntryNotifierProvider._(argument: repository, from: this);

  @override
  String toString() => r'weightEntryProvider';
}

abstract class _$WeightEntryNotifier extends $StreamNotifier<List<WeightEntry>> {
  late final _$args = ref.$arg as BodyWeightRepository?;
  BodyWeightRepository? get repository => _$args;

  Stream<List<WeightEntry>> build([BodyWeightRepository? repository]);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<WeightEntry>>, List<WeightEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<WeightEntry>>, List<WeightEntry>>,
              AsyncValue<List<WeightEntry>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
