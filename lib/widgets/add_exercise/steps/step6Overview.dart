import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/widgets/add_exercise/mixins/image_picker_mixin.dart';
import 'package:wger/widgets/add_exercise/preview_images.dart';

class Step6Overview extends StatefulWidget {
  final GlobalKey<FormState> formkey;

  const Step6Overview({required this.formkey});

  @override
  State<Step6Overview> createState() => _Step6OverviewState();
}

class _Step6OverviewState extends State<Step6Overview> with ExerciseImagePickerMixin {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formkey,
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).add_exercise_image_license,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Consumer<AddExerciseProvider>(
            builder: (ctx, provider, __) => provider.exerciseImages.isNotEmpty
                ? PreviewExerciseImages(
                    selectedImages: provider.exerciseImages,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => pickImages(context, pickFromCamera: true),
                        icon: const Icon(Icons.camera_alt),
                      ),
                      IconButton(
                        onPressed: () => pickImages(context),
                        icon: const Icon(Icons.collections),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
