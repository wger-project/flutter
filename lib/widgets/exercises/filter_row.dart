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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/screens/add_exercise_screen.dart';

import 'filter_modal.dart';

class FilterRow extends StatefulWidget {
  const FilterRow({super.key});

  @override
  _FilterRowState createState() => _FilterRowState();
}

class _FilterRowState extends State<FilterRow> {
  late final TextEditingController _exerciseNameController;

  @override
  void initState() {
    super.initState();

    _exerciseNameController = TextEditingController()
      ..addListener(() {
        final provider = Provider.of<ExercisesProvider>(context, listen: false);
        if (provider.filters!.searchTerm != _exerciseNameController.text) {
          provider.setFilters(provider.filters!.copyWith(searchTerm: _exerciseNameController.text));
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _exerciseNameController,
              decoration: InputDecoration(
                hintText: '${AppLocalizations.of(context).exerciseName}...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const ExerciseFilterModalBody(),
                  );
                },
                icon: const Icon(Icons.filter_alt),
              ),
              PopupMenuButton<ExerciseMoreOption>(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<ExerciseMoreOption>(
                      value: ExerciseMoreOption.ADD_EXERCISE,
                      child: Text(AppLocalizations.of(context).contributeExercise),
                    ),
                  ];
                },
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                onSelected: (ExerciseMoreOption selectedOption) {
                  switch (selectedOption) {
                    case ExerciseMoreOption.ADD_EXERCISE:
                      Navigator.of(context).pushNamed(AddExerciseScreen.routeName);
                      break;
                  }
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }
}

enum ExerciseMoreOption { ADD_EXERCISE }
