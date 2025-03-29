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
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/i18n.dart';
import 'package:wger/helpers/platform.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/image.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/models/exercises/translation.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/exercises/images.dart';
import 'package:wger/widgets/exercises/list_tile.dart';
import 'package:wger/widgets/exercises/videos.dart';

class ExerciseDetail extends StatelessWidget {
  final Exercise _exercise;
  late Translation _translation;
  static const PADDING = 9.0;
  final CarouselController carouselController = CarouselController();

  ExerciseDetail(this._exercise);

  @override
  Widget build(BuildContext context) {
    _translation = _exercise.getTranslation(Localizations.localeOf(context).languageCode);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and equipment
          getCategoriesAndEquipment(context),

          // Alternative names
          ...getAliases(context),

          // Videos
          ...getVideos(),

          // Images
          ...getImages(),

          // Description
          ...getDescription(context),

          // Notes
          ...getNotes(context),

          // Muscles
          ...getMuscles(context),

          // Variants
          ...getVariations(context),
        ],
      ),
    );
  }

  List<Widget> getVariations(BuildContext context) {
    final variations =
        Provider.of<ExercisesProvider>(context, listen: false).findExercisesByVariationId(
      _exercise.variationId,
      exerciseIdToExclude: _exercise.id,
    );

    final List<Widget> out = [];
    if (_exercise.variationId == null) {
      return out;
    }

    out.add(Text(
      AppLocalizations.of(context).variations,
      style: Theme.of(context).textTheme.headlineSmall,
    ));
    for (final element in variations) {
      out.add(ExerciseListTile(exerciseBase: element));
    }
    if (variations.isEmpty) {
      out.add(const Text('-/-'));
    }

    out.add(const SizedBox(height: PADDING));
    return out;
  }

  List<Widget> getNotes(BuildContext context) {
    final List<Widget> out = [];
    if (_translation.notes.isNotEmpty) {
      out.add(Text(
        AppLocalizations.of(context).notes,
        style: Theme.of(context).textTheme.headlineSmall,
      ));
      for (final e in _translation.notes) {
        out.add(Text(e.comment));
      }
      out.add(const SizedBox(height: PADDING));
    }

    return out;
  }

  List<Widget> getMuscles(BuildContext context) {
    final List<Widget> out = [];
    out.add(Text(
      AppLocalizations.of(context).muscles,
      style: Theme.of(context).textTheme.headlineSmall,
    ));
    out.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PADDING),
            child: MuscleWidget(
              muscles: _exercise.muscles,
              musclesSecondary: _exercise.musclesSecondary,
              isFront: true,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PADDING),
            child: MuscleWidget(
              muscles: _exercise.muscles,
              musclesSecondary: _exercise.musclesSecondary,
              isFront: false,
            ),
          ),
        ),
      ],
    ));

    out.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MuscleColorHelper(main: true),
          ..._exercise.muscles.map((e) => Text(e.nameTranslated(context))),
        ],
      ),
    );
    out.add(const SizedBox(height: PADDING));
    out.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MuscleColorHelper(main: false),
          ..._exercise.musclesSecondary.map((e) => Text(e.name)),
        ],
      ),
    );

    out.add(const SizedBox(height: PADDING));

    return out;
  }

  List<Widget> getDescription(BuildContext context) {
    final List<Widget> out = [];
    out.add(Text(
      AppLocalizations.of(context).description,
      style: Theme.of(context).textTheme.headlineSmall,
    ));
    out.add(Html(data: _translation.description));

    return out;
  }

  List<Widget> getImages() {
    // TODO: add carousel for the other images
    final List<Widget> out = [];
    if (_exercise.images.isNotEmpty) {
      out.add(CarouselImages(
        images: _exercise.images,
      ));

      // out.add(ExerciseImageWidget(
      //   image: _exercise.getMainImage,
      //   height: 250,
      // ));
      out.add(const SizedBox(height: PADDING));
    }

    return out;
  }

  Widget getCategoriesAndEquipment(BuildContext context) {
    final List<Widget> out = [];
    final theme = Theme.of(context);

    out.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Chip(
          label: Text(getTranslation(_exercise.category!.name, context)),
          padding: EdgeInsets.zero,
          backgroundColor: theme.splashColor,
        ),
      ),
    );
    if (_exercise.equipment.isNotEmpty) {
      _exercise.equipment
          .map((e) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text(getTranslation(e.name, context)),
                  padding: EdgeInsets.zero,
                  backgroundColor: theme.splashColor,
                ),
              ))
          .forEach((element) => out.add(element));
    }
    out.add(const SizedBox(height: PADDING));
    return Row(children: [...out]);
  }

  List<Widget> getVideos() {
    // TODO: add carousel for the other videos
    final List<Widget> out = [];
    if (_exercise.videos.isNotEmpty && !isDesktop) {
      _exercise.videos.map((v) => ExerciseVideoWidget(video: v)).forEach((element) {
        out.add(element);
      });

      out.add(const SizedBox(height: PADDING));
    }
    return out;
  }

  List<Widget> getAliases(BuildContext context) {
    final List<Widget> out = [];
    if (_translation.aliases.isNotEmpty) {
      out.add(MutedText(
        AppLocalizations.of(context).alsoKnownAs(
          _translation.aliases.map((e) => e.alias).toList().join(', '),
        ),
      ));
      out.add(const SizedBox(height: PADDING));
    }

    return out;
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
        ...musclesSecondary.where((m) => !muscles.contains(m)).map((m) => SvgPicture.asset(
              'assets/images/muscles/secondary/muscle-${m.id}.svg',
            )),
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
              (index) => ExerciseImageWidget(
                image: widget.images[index],
                height: 250,
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
