import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/add_exercise.dart';

const validFileExtensions = ['jpg', 'jpeg', 'png', 'webp'];
const maxFileSize = 20;

mixin ExerciseImagePickerMixin {
  bool _validateFileSize(int fileLength) {
    final kb = fileLength / 1024;
    final mb = kb / 1024;
    return mb > maxFileSize;
  }

  bool _validateFileType(File file) {
    final extension = file.path.split('.').last;
    return validFileExtensions.any((element) => extension == element.toLowerCase());
  }

  void pickImages(BuildContext context, {bool pickFromCamera = false}) async {
    final imagePicker = ImagePicker();

    List<XFile>? images;
    if (pickFromCamera) {
      final pictureTaken = await imagePicker.pickImage(source: ImageSource.camera);
      images = pictureTaken == null ? null : [pictureTaken];
    } else {
      images = await imagePicker.pickMultiImage();
    }

    final selectedImages = <File>[];
    if (images != null) {
      selectedImages.addAll(images.map((e) => File(e.path)).toList());

      for (final image in selectedImages) {
        bool isFileValid = true;
        String errorMessage = '';

        if (!_validateFileType(image)) {
          isFileValid = false;
          errorMessage = "Select only 'jpg', 'jpeg', 'png', 'webp' files";
        }
        if (_validateFileSize(image.lengthSync())) {
          isFileValid = true;
          errorMessage = 'File Size should not be greater than 20 mb';
        }

        if (!isFileValid) {
          if (context.mounted) {
            showDialog(context: context, builder: (context) => Text(errorMessage));
          }
          return;
        }
      }
      context.read<AddExerciseProvider>().addExerciseImages(selectedImages);
    }
  }
}
