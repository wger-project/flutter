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
  final String title;
  final Function callback;
  final List<T> entries;
  final Function displayName;
  final Function? validator;
  const ExerciseCategoryInputWidget(
      {required this.title,
      required this.callback,
      required this.entries,
      required this.displayName,
      this.validator,
      super.key});

  @override
  State<ExerciseCategoryInputWidget> createState() =>
      _ExerciseCategoryInputWidgetState();
}

class _ExerciseCategoryInputWidgetState<T>
    extends State<ExerciseCategoryInputWidget> {
  @override
  Widget build(BuildContext context) {
    T? selectedEntry;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField(
        key: widget.key,
        value: selectedEntry,
        decoration: InputDecoration(
          labelText: widget.title,
          contentPadding: const EdgeInsets.all(8.0),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        onChanged: (T? newValue) {
          setState(() {
            selectedEntry = newValue as T;
            widget.callback(newValue);
          });
        },
        validator: (T? value) {
          if (widget.validator != null) {
            return widget.validator!(value);
          }
          return null;
        },
        items: widget.entries.map<DropdownMenuItem<T>>((value) {
          return DropdownMenuItem<T>(
            key: Key(value.id.toString()),
            value: value,
            child: Text(widget.displayName(value)),
          );
        }).toList(),
      ),
    );
  }
}
