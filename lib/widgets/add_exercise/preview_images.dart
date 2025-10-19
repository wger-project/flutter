import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/exercises/exercise_submission_images.dart';
import 'package:wger/providers/add_exercise.dart';

/// Widget to preview selected exercise images
///
/// Displays images in a horizontal scrollable list with thumbnails.
/// Each image shows a preview thumbnail and optionally a delete button.
/// Can optionally include an "add more" button at the end of the list.
class PreviewExerciseImages extends StatelessWidget {
  final List<ExerciseSubmissionImage> selectedImages;
  final VoidCallback? onAddMore;
  final bool allowEdit;

  const PreviewExerciseImages({
    super.key,
    required this.selectedImages,
    this.onAddMore,
    this.allowEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate item count: images + optional "add more" button
    final itemCount = selectedImages.length + (allowEdit && onAddMore != null ? 1 : 0);

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Show "add more" button at the end (only if editing is allowed)
          if (index == selectedImages.length) {
            return _buildAddMoreButton(context);
          }

          // Show image thumbnail
          final image = selectedImages[index];
          return _buildImageCard(context, image.imageFile);
        },
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, File image) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Image thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(image, width: 120, height: 120, fit: BoxFit.cover),
          ),

          // Delete button overlay (only shown if editing is allowed)
          if (allowEdit)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: Colors.white,
                iconSize: 20,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  padding: const EdgeInsets.all(4),
                ),
                onPressed: () {
                  context.read<AddExerciseProvider>().removeImage(image.path);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: onAddMore,
      child: Container(
        width: 120,
        height: 120,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Icon(Icons.add, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
