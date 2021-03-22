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

Future<Widget?> showFormBottomSheet(BuildContext context, String header, Widget form,
    {bool scrollControlled: false}) async {
  return showModalBottomSheet(
      isScrollControlled: scrollControlled,
      context: context,
      builder: (BuildContext ctx) {
        return Column(
          children: [
            Icon(
              Icons.remove,
              color: Colors.grey,
            ),
            Text(
              header,
              style: Theme.of(ctx).textTheme.headline6,
            ),
            SizedBox(height: 10),
            Divider(),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: form,
            )
          ],
        );
      });
}
