import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/add_exercise.dart';

import 'mixins/image_picker_mixin.dart';

class PreviewExerciseImages extends StatelessWidget with ExerciseImagePickerMixin {
  final List<File> selectedImages;
  final bool allowEdit;

  const PreviewExerciseImages({super.key, required this.selectedImages, this.allowEdit = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView(scrollDirection: Axis.horizontal, children: [
        ...selectedImages.map(
          (file) => SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Image.file(file),
                  if (allowEdit)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: IconButton(
                            iconSize: 20,
                            onPressed: () =>
                                context.read<AddExerciseProvider>().removeExercise(file.path),
                            color: Colors.white,
                            icon: const Icon(Icons.delete),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (allowEdit)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.grey,
              height: 200,
              width: 100,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => pickImages(context),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}
