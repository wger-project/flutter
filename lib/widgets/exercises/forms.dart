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

/// Input widget for exercise category objects
///
/// Can be used with a Setting or a Log object
class ExerciseCategoryInputWidget<T> extends StatefulWidget {
  late final String _title;
  late final Function _callback;
  late final List<T> _categories;

  ExerciseCategoryInputWidget({
    required String title,
    required List<T> categories,
    required Function callback,
  }) {
    _categories = categories;
    _title = title;
    _callback = callback;
  }

  @override
  _ExerciseCategoryInputWidgetState createState() => _ExerciseCategoryInputWidgetState<T>();
}

class _ExerciseCategoryInputWidgetState<T> extends State<ExerciseCategoryInputWidget> {
  @override
  Widget build(BuildContext context) {
    T selectedWeightUnit = widget._categories.first;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField(
        value: selectedWeightUnit,
        decoration: InputDecoration(
          labelText: widget._title,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        isDense: true,
        onChanged: (T? newValue) {
          setState(() {
            selectedWeightUnit = newValue!;
            widget._callback(newValue);
          });
        },
        items: widget._categories.map<DropdownMenuItem<T>>((value) {
          return DropdownMenuItem<T>(
            key: Key(value.id.toString()),
            value: value,
            child: Text(value.name),
          );
        }).toList(),
      ),
    );
  }
}
