/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020, 2021 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/widgets/exercises/detail/aliases_section.dart';
import 'package:wger/widgets/exercises/detail/category_equipment_row.dart';
import 'package:wger/widgets/exercises/detail/description_section.dart';
import 'package:wger/widgets/exercises/detail/images_section.dart';
import 'package:wger/widgets/exercises/detail/muscles_section.dart';
import 'package:wger/widgets/exercises/detail/notes_section.dart';
import 'package:wger/widgets/exercises/detail/variations_section.dart';
import 'package:wger/widgets/exercises/detail/videos_section.dart';
import 'package:wger/widgets/exercises/images.dart';

class ExerciseDetail extends StatelessWidget {
  final Exercise _exercise;

  const ExerciseDetail(this._exercise, {super.key});

  @override
  Widget build(BuildContext context) {
    final translation = _exercise.getTranslation(Localizations.localeOf(context).languageCode);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryEquipmentRow(exercise: _exercise),
          AliasesSection(translation: translation),
          VideosSection(exercise: _exercise),
          ImagesSection(exercise: _exercise),
          DescriptionSection(translation: translation),
          NotesSection(translation: translation),
          MusclesSection(exercise: _exercise),
          VariationsSection(exercise: _exercise),
        ],
      ),
    );
  }
}

class MuscleColorHelper extends StatelessWidget {
  final bool main;

  const MuscleColorHelper({this.main = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 16,
          width: 16,
          color: main ? COLOR_MAIN_MUSCLES : COLOR_SECONDARY_MUSCLES,
        ),
        const SizedBox(width: 2),
        Text(
          main
              ? AppLocalizations.of(context).muscles
              : AppLocalizations.of(context).musclesSecondary,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class MuscleRowWidget extends StatelessWidget {
  final List<Muscle> muscles;
  final List<Muscle> musclesSecondary;

  const MuscleRowWidget({
    required this.muscles,
    required this.musclesSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceAround,
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: MuscleWidget(
              muscles: muscles,
              musclesSecondary: musclesSecondary,
              isFront: true,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: MuscleWidget(
              muscles: muscles,
              musclesSecondary: musclesSecondary,
              isFront: false,
            ),
          ),
        ),
      ],
    );
  }
}

class MuscleWidget extends StatelessWidget {
  late final List<Muscle> muscles;
  late final List<Muscle> musclesSecondary;
  final bool isFront;

  MuscleWidget({
    List<Muscle> muscles = const [],
    List<Muscle> musclesSecondary = const [],
    this.isFront = true,
  }) {
    this.muscles = muscles.where((m) => m.isFront == isFront).toList();
    this.musclesSecondary = musclesSecondary.where((m) => m.isFront == isFront).toList();
  }

  @override
  Widget build(BuildContext context) {
    final background = isFront ? 'front' : 'back';

    return Stack(
      children: [
        SvgPicture.asset('assets/images/muscles/$background.svg'),
        ...muscles.map((m) => SvgPicture.asset('assets/images/muscles/main/muscle-${m.id}.svg')),
        ...musclesSecondary
            .where((m) => !muscles.contains(m))
            .map(
              (m) => SvgPicture.asset(
                'assets/images/muscles/secondary/muscle-${m.id}.svg',
              ),
            ),
      ],
    );
  }
}

class CarouselImages extends StatefulWidget {
  final List<ExerciseImage> images;

  const CarouselImages({super.key, required this.images});

  @override
  State<CarouselImages> createState() => _CarouselImagesState();
}

class _CarouselImagesState extends State<CarouselImages> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              onPageChanged: (index, _) => setState(() => pageIndex = index),
            ),
            items: List.generate(
              widget.images.length,
              (index) => Padding(
                padding: const EdgeInsets.only(top: 15),
                child: ExerciseImageWidget(
                  image: widget.images[index],
                  height: 260,
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: List.generate(
              widget.images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: pageIndex == index ? Colors.black : Colors.black26,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
