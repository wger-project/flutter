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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/gallery/image.dart';
import 'package:wger/providers/gallery_notifier.dart';
import 'package:wger/providers/network_provider.dart';
import 'package:wger/widgets/core/datetime_input.dart';
import 'package:wger/widgets/core/form_submit_button.dart';
import 'package:wger/widgets/core/wger_image.dart';

class ImageForm extends ConsumerStatefulWidget {
  late final GalleryImage _image;

  ImageForm([GalleryImage? image]) {
    _image = image ?? GalleryImage.empty();
  }

  @override
  ConsumerState<ImageForm> createState() => _ImageFormState();
}

class _ImageFormState extends ConsumerState<ImageForm> {
  final _form = GlobalKey<FormState>();

  XFile? _file;

  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    descriptionController.text = widget._image.description;
  }

  void _showPicker(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);

    setState(() {
      _file = file;
    });
  }

  /// Returns widget with current picture, depending on whether the user is
  /// editing an existing entry or adding a new one. A text message is shown if
  /// neither is available
  Widget getPicture() {
    // An image file was selected, use it
    if (_file != null) {
      return Image(image: FileImage(File(_file!.path)));
    }

    // We are editing an existing entry
    if (widget._image.imagePath != null) {
      return WgerImage(
        mediaPath: widget._image.imagePath,
        fit: BoxFit.contain,
      );
    }

    // No picture available, show a message to the user
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppLocalizations.of(context).selectImage),
        const SizedBox(height: 8),
        const Icon(Icons.photo_camera),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(networkStatusProvider);
    // Creating an image or replacing its photo is a binary REST upload and
    // needs connectivity. A metadata-only edit syncs through PowerSync and
    // works offline.
    final requiresUpload = widget._image.id == null || _file != null;

    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return SizedBox(
                      height: 150,
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pop();
                              _showPicker(ImageSource.camera);
                            },
                            leading: const Icon(Icons.photo_camera),
                            title: Text(AppLocalizations.of(context).takePicture),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pop();
                              _showPicker(ImageSource.gallery);
                            },
                            leading: const Icon(Icons.photo_library),
                            title: Text(
                              AppLocalizations.of(context).chooseFromLibrary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: getPicture(),
            ),
          ),
          DateInputWidget(
            key: const Key('field-date'),
            value: widget._image.date,
            labelText: AppLocalizations.of(context).date,
            firstDate: DateTime.now().subtract(const Duration(days: 3000)),
            lastDate: DateTime.now(),
            onChanged: (date) => widget._image.date = date,
            validator: (value) {
              if (widget._image.id == null && _file == null) {
                return AppLocalizations.of(context).selectImage;
              }
              return null;
            },
          ),
          TextFormField(
            key: const Key('field-description'),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).description,
            ),
            minLines: 3,
            maxLines: 10,
            maxLength: GalleryImage.MAX_LENGTH_DESCRIPTION,
            controller: descriptionController,
            onSaved: (newValue) {
              widget._image.description = newValue!;
            },
          ),
          FormSubmitButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            enabled: !(requiresUpload && !isOnline),
            label: AppLocalizations.of(context).save,
            onPressed: () async {
              // Validate and save
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              final notifier = ref.read(galleryProvider.notifier);
              if (widget._image.id == null) {
                await notifier.addImage(widget._image, _file!);
              } else {
                await notifier.editImage(widget._image, _file);
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
