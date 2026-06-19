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

/// Art style of an [ExerciseImage].
///
/// The wire values mirror Django's `ExerciseImage.STYLE` choices (`CharField`
/// with `'1'`–`'5'`), so the same string round-trips through PowerSync
/// without any extra mapping on the connector.
enum ExerciseImageStyle {
  lineArt('1'),
  threeD('2'),
  lowPoly('3'),
  photo('4'),
  other('5');

  final String wireValue;
  const ExerciseImageStyle(this.wireValue);

  /// Looks up an enum case by its Django wire value.
  static ExerciseImageStyle fromWire(String value) =>
      ExerciseImageStyle.values.firstWhere((e) => e.wireValue == value);
}

class ExerciseImage {
  final int id;
  final String uuid;
  final int exerciseId;

  /// Relative path of the image on the server (Django `ImageField`),
  /// e.g. `exercise-images/91/foo.png`
  final String image;

  final bool isMain;
  final bool isAiGenerated;
  final ExerciseImageStyle style;

  final int? width;
  final int? height;
  final DateTime created;
  final DateTime lastUpdate;

  /// FK to the `License` row.
  final int licenseId;
  final String licenseTitle;
  final String licenseObjectUrl;

  /// Author may be null on the server (`TextField(null=True)`).
  final String? licenseAuthor;
  final String licenseAuthorUrl;
  final String licenseDerivativeSourceUrl;

  const ExerciseImage({
    required this.id,
    required this.uuid,
    required this.exerciseId,
    required this.image,
    required this.isMain,
    required this.isAiGenerated,
    required this.style,
    required this.width,
    required this.height,
    required this.created,
    required this.lastUpdate,
    required this.licenseId,
    required this.licenseTitle,
    required this.licenseObjectUrl,
    required this.licenseAuthor,
    required this.licenseAuthorUrl,
    required this.licenseDerivativeSourceUrl,
  });

  @override
  String toString() {
    return 'Image $id: $image';
  }
}
