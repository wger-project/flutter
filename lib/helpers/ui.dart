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

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wger/exceptions/http_exception.dart';

void showErrorDialog(dynamic exception, BuildContext context) {
  log('showErrorDialog: ');
  log(exception.toString());
  log('=====================');

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(AppLocalizations.of(context).anErrorOccurred),
      content: Text(exception.toString()),
      actions: [
        TextButton(
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        )
      ],
    ),
  );
}

void showHttpExceptionErrorDialog(WgerHttpException exception, BuildContext context) {
  log('showHttpExceptionErrorDialog: ');
  log(exception.toString());
  log('-------------------');

  List<Widget> errorList = [];
  for (var key in exception.errors!.keys) {
    // Error headers
    errorList.add(Text(key, style: TextStyle(fontWeight: FontWeight.bold)));

    // Error messages
    if (exception.errors![key] is String) {
      errorList.add(Text(exception.errors![key]));
    } else {
      for (var value in exception.errors![key]) {
        errorList.add(Text(value));
      }
    }
    errorList.add(SizedBox(height: 8));
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
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        )
      ],
    ),
  );
}
