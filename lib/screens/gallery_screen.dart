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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/workout_plans.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/core/core.dart';
import 'package:wger/widgets/gallery/overview.dart';

class GalleryScreen extends StatefulWidget {
  static const routeName = '/gallery';

  const GalleryScreen();

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  PickedFile? _file;

  void _showPhotoLibrary() async {
    final picker = ImagePicker();
    final file = await picker.getImage(source: ImageSource.gallery);

    print(file);
    setState(() {
      _file = file!;
    });
  }

  void _showCamera(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.getImage(source: ImageSource.camera);

    print(_file);
    setState(() {
      _file = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WgerAppBar(
        AppLocalizations.of(context)!.labelWorkoutPlans,
      ),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                height: 150,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showCamera(context);
                      },
                      leading: Icon(Icons.photo_camera),
                      title: Text("Take a picture"),
                    ),
                    ListTile(
                        onTap: () {
                          Navigator.of(context).pop();
                          _showPhotoLibrary();
                        },
                        leading: Icon(Icons.photo_library),
                        title: Text("Choose from photo library"))
                  ],
                ),
              );
            },
          );
        },
      ),
      body: Consumer<WorkoutPlans>(
        builder: (context, workoutProvider, child) => Gallery(),
      ),
    );
  }
}
