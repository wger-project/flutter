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
import 'package:wger/screens/form_screen.dart';
import 'package:wger/theme/theme.dart';

class NothingFound extends StatelessWidget {
  final String _title;
  final String _titleForm;
  final Widget _form;

  const NothingFound(this._title, this._titleForm, this._form);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_title),
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.add_box, color: wgerPrimaryButtonColor),
            onPressed: () {
              Navigator.pushNamed(
                context,
                FormScreen.routeName,
                arguments: FormScreenArguments(
                  _titleForm,
                  hasListView: true,
                  _form,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
