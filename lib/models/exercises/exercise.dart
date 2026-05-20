/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
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
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/models/exercises/equipment.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/models/exercises/video.dart';

class Exercise extends Equatable {
  static final _logger = Logger('ExerciseModel');

  final int id;
  final String uuid;
  final String? variationGroup;
  final DateTime? created;
  final DateTime? lastUpdate;
  final ExerciseCategory category;
  final List<Muscle> muscles;
  final List<Muscle> musclesSecondary;
  final List<Equipment> equipment;
  final List<ExerciseImage> images;
  final List<Translation> translations;
  final List<Video> videos;
  final List<String> authors;
  final List<String> authorsGlobal;

  int get categoryId => category.id;
  List<int> get musclesIds => muscles.map((e) => e.id).toList();
  List<int> get musclesSecondaryIds => musclesSecondary.map((e) => e.id).toList();
  List<int> get equipmentIds => equipment.map((e) => e.id).toList();

  const Exercise({
    required this.id,
    required this.uuid,
    this.created,
    this.lastUpdate,
    this.variationGroup,
    required this.category,
    this.muscles = const [],
    this.musclesSecondary = const [],
    this.equipment = const [],
    this.images = const [],
    this.translations = const [],
    this.videos = const [],
    this.authors = const [],
    this.authorsGlobal = const [],
  });

  Exercise copyWith({
    int? id,
    String? uuid,
    DateTime? created,
    DateTime? lastUpdate,
    String? variationGroup,
    ExerciseCategory? category,
    List<Muscle>? muscles,
    List<Muscle>? musclesSecondary,
    List<Equipment>? equipment,
    List<ExerciseImage>? images,
    List<Translation>? translations,
    List<Video>? videos,
    List<String>? authors,
    List<String>? authorsGlobal,
  }) {
    return Exercise(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      created: created ?? this.created,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      variationGroup: variationGroup ?? this.variationGroup,
      category: category ?? this.category,
      muscles: muscles ?? this.muscles,
      musclesSecondary: musclesSecondary ?? this.musclesSecondary,
      equipment: equipment ?? this.equipment,
      images: images ?? this.images,
      translations: translations ?? this.translations,
      videos: videos ?? this.videos,
      authors: authors ?? this.authors,
      authorsGlobal: authorsGlobal ?? this.authorsGlobal,
    );
  }

  bool get showPlateCalculator => equipment.map((e) => e.id).contains(ID_EQUIPMENT_BARBELL);

  /// Returns translation for the given language
  ///
  /// If no translation is found, English will be returned
  ///
  /// Note: we return the first translation as a fallback if we don't find a
  ///       translation in English. This is something that should never happen,
  ///       but we can't make sure that no local installation hasn't deleted
  ///       the entry in English.
  Translation getTranslation(String language) {
    // If the language is in the form en-US, take the language code only
    final languageCode = language.split('-')[0];

    return translations.firstWhere(
      (e) => e.language.shortName == languageCode,
      orElse: () => translations.firstWhere(
        (e) => e.language.shortName == LANGUAGE_SHORT_ENGLISH,
        orElse: () {
          _logger.info(
            'Could not find fallback english translation for exercise-ID $id, returning '
            'first language (${translations.first.language.shortName}) instead.',
          );
          return translations.first;
        },
      ),
    );
  }

  ExerciseImage? get getMainImage {
    return images.firstWhereOrNull((image) => image.isMain);
  }

  @override
  List<Object?> get props => [
    id,
    uuid,
    created,
    lastUpdate,
    category,
    equipment,
    muscles,
    musclesSecondary,
  ];
}
