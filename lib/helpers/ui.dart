/*
 * This file is part of wger Workout Manager.
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
 */

import 'package:flutter/material.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/http_exception.dart';

void showErrorDialog(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('An Error Occurred!'),
      content: Text(message),
      actions: [
        TextButton(
          child: Text('Dismiss'),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        )
      ],
    ),
  );
}

void showHttpExceptionErrorDialog(HttpException exception, BuildContext context) {
  List<Widget> errorList = [];
  for (var key in exception.errors.keys) {
    // Error headers
    errorList.add(Text(key, style: TextStyle(fontWeight: FontWeight.bold)));

    // Error messages
    for (var value in exception.errors[key]) {
      errorList.add(Text(value));
    }
  }

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(AppLocalizations.of(context).anErrorOccurred),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [...errorList],
        ),
      ),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context).dismiss),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        )
      ],
    ),
  );
}
