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

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/gallery.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/gallery/forms.dart';
import 'package:wger/widgets/gallery/overview.dart';

import 'form_screen.dart';

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen(this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  static const routeName = '/gallery';

  const GalleryScreen();

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  PickedFile? _file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WgerAppBar(
        AppLocalizations.of(context)!.gallery,
      ),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(
            context,
            FormScreen.routeName,
            arguments: FormScreenArguments(
              AppLocalizations.of(context)!.addImage,
              ImageForm(),
              true,
            ),
          );
        },
      ),
      body: Consumer<GalleryProvider>(
        builder: (context, workoutProvider, child) => Gallery(),
      ),
    );
  }
}
