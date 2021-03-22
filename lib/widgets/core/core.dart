/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (C) 2020 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * wger Workout Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:wger/theme/theme.dart';

class MutedText extends StatelessWidget {
  String _text;
  MutedText(
    this._text, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(_text, style: TextStyle(color: wgerTextMuted));
  }
}

/// Appbar that extends [PreferredSizeWidget]
class WgerAppBar extends StatelessWidget with PreferredSizeWidget {
  String _title;

  WgerAppBar(this._title);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(_title),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
