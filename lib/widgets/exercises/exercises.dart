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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/models/exercises/muscle.dart';
import 'package:wger/widgets/exercises/images.dart';
import 'package:wger/widgets/exercises/videos.dart';

class ExerciseDetail extends StatelessWidget {
  final Exercise _exercise;
  static const PADDING = 9.0;

  const ExerciseDetail(this._exercise);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and equipment
          getCategoriesAndEquipment(),

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
        ],
      ),
    );
  }

  List<Widget> getNotes(BuildContext context) {
    final List<Widget> out = [];
    if (_exercise.tips.isNotEmpty) {
      out.add(Text(
        AppLocalizations.of(context).notes,
        style: Theme.of(context).textTheme.headline5,
      ));
      for (final e in _exercise.tips) {
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
      style: Theme.of(context).textTheme.headline5,
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
          Row(
            children: [
              Container(
                height: 16,
                width: 16,
                color: Colors.red,
              ),
              const SizedBox(width: 2),
              Text(
                AppLocalizations.of(context).muscles,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ..._exercise.muscles.map((e) => Text(e.name)).toList(),
        ],
      ),
    );
    out.add(const SizedBox(height: PADDING));
    out.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 16,
                width: 16,
                color: Colors.orange,
              ),
              const SizedBox(width: 2),
              Text(
                AppLocalizations.of(context).musclesSecondary,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ..._exercise.musclesSecondary.map((e) => Text(e.name)).toList(),
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
      style: Theme.of(context).textTheme.headline5,
    ));
    out.add(Html(data: _exercise.description));

    return out;
  }

  List<Widget> getImages() {
    // TODO: add carousel for the other images
    final List<Widget> out = [];
    if (_exercise.getMainImage != null) {
      out.add(ExerciseImageWidget(image: _exercise.getMainImage));
      out.add(const SizedBox(height: PADDING));
    }

    return out;
  }

  Widget getCategoriesAndEquipment() {
    final List<Widget> out = [];

    out.add(Chip(
      label: Text(_exercise.categoryObj.name),
    ));
    if (_exercise.equipment.isNotEmpty) {
      _exercise.equipment.map((e) => Chip(label: Text(e.name))).forEach((element) {
        out.add(element);
      });
    }
    out.add(const SizedBox(height: PADDING));
    return Row(children: [...out]);
  }

  List<Widget> getVideos() {
    // TODO: add carousel for the other videos
    final List<Widget> out = [];
    if (_exercise.videos.isNotEmpty) {
      _exercise.videos.map((v) => ExerciseVideoWidget(video: v)).forEach((element) {
        out.add(element);
      });

      out.add(const SizedBox(height: PADDING));
    }
    return out;
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
    final muscleFolder = isFront ? 'main' : 'secondary';

    return Stack(
      children: [
        SvgPicture.asset('assets/images/muscles/$background.svg'),
        ...muscles
            .map((m) => SvgPicture.asset('assets/images/muscles/main/muscle-${m.id}.svg'))
            .toList(),
        ...musclesSecondary
            .map((m) => SvgPicture.asset('assets/images/muscles/$muscleFolder/muscle-${m.id}.svg'))
            .toList(),
      ],
    );
  }
}
