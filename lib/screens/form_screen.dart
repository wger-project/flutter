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
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';

/// Arguments passed to the form screen
class FormScreenArguments {
  /// Title
  final String title;

  /// Widget to render, typically a form
  final Widget widget;

  /// Flag indicating whether to render the content has a list view (e.g. larger
  /// forms that use an autocompleter, etc) or not (smnall forms, content will
  /// get pushed down)
  final bool hasListView;
  FormScreenArguments(this.title, this.widget, [this.hasListView = false]);
}

class FormScreen extends StatelessWidget {
  static const routeName = '/form';

  @override
  Widget build(BuildContext context) {
    final FormScreenArguments args =
        ModalRoute.of(context)!.settings.arguments as FormScreenArguments;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(args.title)),
      body: args.hasListView
          ? Padding(
              padding: const EdgeInsets.all(15.0),
              child: args.widget,
            )
          : Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: args.widget,
                ),
              ],
            ),
    );
  }
}
