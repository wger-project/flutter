import 'package:flutter/material.dart';
import 'package:wger/core/validators.dart';
import 'package:wger/helpers/exercises/validators.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/models/exercises/exercise_submission_images.dart';
import 'package:wger/widgets/add_exercise/license_info_widget.dart';

import 'add_exercise_text_area.dart';

/// Form for collecting CC BY-SA 4.0 license metadata for exercise images
///
/// This form is displayed after image selection in Step 5 of exercise creation.
/// It collects all required and optional license attribution fields:
///
/// Required by CC BY-SA 4.0:
/// - Author name
/// - License type (implicitly CC BY-SA 4.0)
///
/// Optional but recommended:
/// - Title (helps identify the image)
/// - Source URL (where image was found)
/// - Author URL (author's website/profile)
/// - Derivative source URL (if modified from another work)
/// - Image style (PHOTO, 3D, LINE, LOW-POLY, OTHER)
///
/// All metadata is sent to the API's /exerciseimage endpoint along with
/// the image file when the exercise is submitted.
class ImageDetailsForm extends StatefulWidget {
  final Function(ExerciseSubmissionImage image) onAdd;
  final VoidCallback onCancel;
  final ExerciseSubmissionImage submissionImage;

  const ImageDetailsForm({
    super.key,
    required this.submissionImage,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  State<ImageDetailsForm> createState() => _ImageDetailsFormState();
}

class _ImageDetailsFormState extends State<ImageDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for license metadata fields
  final _titleController = TextEditingController();
  final _sourceLinkController = TextEditingController();
  final _authorController = TextEditingController();
  final _authorLinkController = TextEditingController();
  final _originalSourceController = TextEditingController();

  /// Currently selected image type
  ImageType _selectedImageType = ImageType.photo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sourceLinkController.dispose();
    _authorController.dispose();
    _authorLinkController.dispose();
    _originalSourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).imageDetailsTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildImagePreview(),
            const SizedBox(height: 8),

            // Author name - required for proper CC BY-SA attribution
            AddExerciseTextArea(
              title: '${AppLocalizations.of(context).author}*',
              initialValue: widget.submissionImage.author,
              onSaved: (value) => widget.submissionImage.author = value!,
              validator: (name) => validateAuthorName(name, context),
            ),

            // License title field - helps identify the image
            AddExerciseTextArea(
              title: AppLocalizations.of(context).imageDetailsLicenseTitle,
              helperText: AppLocalizations.of(context).imageDetailsLicenseTitleHint,
              initialValue: widget.submissionImage.title,
              onSaved: (value) => widget.submissionImage.title = value,
            ),

            // Source URL - where the image was found (license_object_url in API)
            AddExerciseTextArea(
              title: AppLocalizations.of(context).imageDetailsSourceLink,
              initialValue: widget.submissionImage.sourceUrl,
              onSaved: (value) => widget.submissionImage.sourceUrl = value,
              validator: (value) => validateUrl(value, i18n, required: false),
            ),

            // Author's website/profile URL
            AddExerciseTextArea(
              title: AppLocalizations.of(context).imageDetailsAuthorLink,
              initialValue: widget.submissionImage.authorUrl,
              onSaved: (value) => widget.submissionImage.authorUrl = value,
              validator: (value) => validateUrl(value, i18n, required: false),
            ),

            // Original source if this is a derivative work (modified from another image)
            AddExerciseTextArea(
              title: AppLocalizations.of(context).imageDetailsDerivativeSource,
              helperText: AppLocalizations.of(context).imageDetailsDerivativeHelp,
              initialValue: widget.submissionImage.derivativeSourceUrl,
              onSaved: (value) => widget.submissionImage.derivativeSourceUrl = value,
              validator: (value) => validateUrl(value, i18n, required: false),
            ),

            _buildImageTypeSelector(),
            const SizedBox(height: 16),

            // License info as separate widget for better optimization
            const LicenseInfoWidget(),
            const SizedBox(height: 8),

            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(widget.submissionImage.imageFile, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperMaxLines: 3,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  /// Visual selector for image style/type
  ///
  /// Allows user to categorize the image as PHOTO, 3D render, LINE drawing,
  /// LOW-POLY art, or OTHER. This helps users find appropriate exercise images.
  Widget _buildImageTypeSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).imageDetailsImageType,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ImageType.values.map((type) {
            final isSelected = _selectedImageType == type;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedImageType = type;
                });
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.buttonTheme.colorScheme!.primary
                      : theme.buttonTheme.colorScheme!.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type.icon,
                      size: 32,
                      color: isSelected
                          ? theme.buttonTheme.colorScheme!.onPrimary
                          : theme.buttonTheme.colorScheme!.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? theme.buttonTheme.colorScheme!.onPrimary
                            : theme.buttonTheme.colorScheme!.primary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            // Add optional fields only if user provided values
            final title = _titleController.text.trim();
            if (title.isNotEmpty) {
              widget.submissionImage.title = title;
            }

            final author = _authorController.text.trim();
            if (author.isNotEmpty) {
              widget.submissionImage.author = author;
            }

            final sourceUrl = _sourceLinkController.text.trim();
            if (sourceUrl.isNotEmpty) {
              widget.submissionImage.sourceUrl = sourceUrl;
            }

            final authorUrl = _authorLinkController.text.trim();
            if (authorUrl.isNotEmpty) {
              widget.submissionImage.authorUrl = authorUrl;
            }

            final derivativeUrl = _originalSourceController.text.trim();
            if (derivativeUrl.isNotEmpty) {
              widget.submissionImage.derivativeSourceUrl = derivativeUrl;
            }

            // Pass image and metadata back to parent
            widget.onAdd(widget.submissionImage);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: Text(
            AppLocalizations.of(context).add,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
