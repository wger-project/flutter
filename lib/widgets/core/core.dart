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

class MutedText extends StatelessWidget {
  final String _text;
  final TextAlign textAlign;
  final TextOverflow? overflow;

  const MutedText(
    this._text, {
    this.textAlign = TextAlign.left,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: TextStyle(color: Theme.of(context).colorScheme.outline),
      textAlign: textAlign,
      overflow: overflow,
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight.withOpacity(0.15),
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(title),
    );
  }
}

class CircleIconAvatar extends StatelessWidget {
  final double radius;
  final Icon _icon;

  final Color color;

  const CircleIconAvatar(this._icon, {this.radius = 20, this.color = Colors.black12});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: color,
      radius: radius,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: _icon,
      ),
    );
  }
}
