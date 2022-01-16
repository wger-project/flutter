import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/add_excercise_provider.dart';

const validFileExtensions = ['jpg', 'jpeg', 'png', 'webp'];
const maxFileSize = 20;

mixin ExcerciseImagePickerMixin {
  bool _validateFileType(int fileLength) {
    final kb = fileLength / 1024;
    final mb = kb / 1024;
    return mb > maxFileSize;
  }

  bool _validateFileSize(File file) {
    final extension = file.path.split('.').last;
    return validFileExtensions.any((element) => extension == element.toLowerCase());
  }

  void pickImages(BuildContext context) async {
    final imagePicker = ImagePicker();
    final images = await imagePicker.pickMultiImage();
    final selectedImages = <File>[];
    if (images != null) {
      selectedImages.addAll(images.map((e) => File(e.path)).toList());

      for (final image in selectedImages) {
        bool isFileValid = true;
        String errorMessage = '';

        if (!_validateFileSize(image)) {
          isFileValid = false;
          errorMessage = "Select only 'jpg', 'jpeg', 'png', 'webp' files";
        }
        if (_validateFileType(image.lengthSync())) {
          isFileValid = true;
          errorMessage = 'File Size should not be greater than 20 mb';
        }

        if (!isFileValid) {
          showDialog(context: context, builder: (context) => Text(errorMessage));
          return;
        }
      }
      context.read<AddExcerciseProvider>().addExcerciseImages(selectedImages);
    }
  }
}
