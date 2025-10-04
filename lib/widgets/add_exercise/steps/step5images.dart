import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/widgets/add_exercise/mixins/image_picker_mixin.dart';
import 'package:wger/widgets/add_exercise/preview_images.dart';
import 'package:wger/widgets/add_exercise/image_details_form.dart';

class Step5Images extends StatefulWidget {
  final GlobalKey<FormState> formkey;
  const Step5Images({required this.formkey});

  @override
  State<Step5Images> createState() => _Step5ImagesState();
}

class _Step5ImagesState extends State<Step5Images> with ExerciseImagePickerMixin {
  File? _currentImageToAdd;

  /// Pick image and show details form for license metadata
  void _pickAndShowImageDetails(BuildContext context, {bool pickFromCamera = false}) async {
    final imagePicker = ImagePicker();

    XFile? selectedImage;
    if (pickFromCamera) {
      selectedImage = await imagePicker.pickImage(source: ImageSource.camera);
    } else {
      selectedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    }

    if (selectedImage != null) {
      final imageFile = File(selectedImage.path);

      // Validate file type and size
      bool isFileValid = true;
      String errorMessage = '';

      final extension = imageFile.path.split('.').last;
      const validFileExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      if (!validFileExtensions.any((ext) => extension.toLowerCase() == ext)) {
        isFileValid = false;
        errorMessage = "Select only 'jpg', 'jpeg', 'png', 'webp' files";
      }

      final fileSizeInMB = imageFile.lengthSync() / 1024 / 1024;
      if (fileSizeInMB > 20) {
        isFileValid = false;
        errorMessage = 'File Size should not be greater than 20 MB';
      }

      if (!isFileValid) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
        return;
      }

      // Show details form for valid image
      setState(() {
        _currentImageToAdd = imageFile;
      });
    }
  }

  /// Add image with license metadata to provider
  void _addImageWithDetails(File image, Map<String, String> details) {
    final provider = context.read<AddExerciseProvider>();

    provider.addExerciseImages(
      [image],
      title: details['license_title'],
      author: details['license_author'],
      authorUrl: details['license_author_url'],
      sourceUrl: details['license_object_url'],
      derivativeSourceUrl: details['license_derivative_source_url'],
      style: details['style'] ?? '1',
    );

    setState(() {
      _currentImageToAdd = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image added with details'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _cancelImageAdd() {
    setState(() {
      _currentImageToAdd = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formkey,
      child: Column(
        children: [
          // Show license notice when not adding image
          if (_currentImageToAdd == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                AppLocalizations.of(context).add_exercise_image_license,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),

          // Show image details form when image is selected
          if (_currentImageToAdd != null)
            ImageDetailsForm(
              imageFile: _currentImageToAdd!,
              onAdd: _addImageWithDetails,
              onCancel: _cancelImageAdd,
            ),

          // Show image picker or preview when no image is being added
          if (_currentImageToAdd == null)
            Consumer<AddExerciseProvider>(
              builder: (ctx, provider, __) {
                if (provider.exerciseImages.isNotEmpty) {
                  // Show preview of existing images
                  return Column(
                    children: [
                      PreviewExerciseImages(
                        selectedImages: provider.exerciseImages,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _pickAndShowImageDetails(context),
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Another Image'),
                      ),
                    ],
                  );
                }

                // Show empty state with camera/gallery buttons
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    Icon(
                      Icons.add_photo_alternate,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No images selected',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickAndShowImageDetails(
                            context,
                            pickFromCamera: true,
                          ),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => _pickAndShowImageDetails(context),
                          icon: const Icon(Icons.collections),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Only JPEG, PNG and WEBP files below 20 MB are supported',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}