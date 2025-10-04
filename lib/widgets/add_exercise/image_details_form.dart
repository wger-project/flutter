import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/widgets/add_exercise/license_info_widget.dart';

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
  final File imageFile;
  final Function(File image, Map<String, String> details) onAdd;
  final VoidCallback onCancel;

  const ImageDetailsForm({
    Key? key,
    required this.imageFile,
    required this.onAdd,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<ImageDetailsForm> createState() => _ImageDetailsFormState();
}

class _ImageDetailsFormState extends State<ImageDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers for license metadata fields
  final _titleController = TextEditingController();
  final _sourceLinkController = TextEditingController(); // license_object_url in API
  final _authorController = TextEditingController(); // license_author in API
  final _authorLinkController = TextEditingController(); // license_author_url in API
  final _originalSourceController = TextEditingController(); // license_derivative_source_url in API

  /// Currently selected image type
  /// Maps to API 'style' field: PHOTO=1, 3D=2, LINE=3, LOW-POLY=4, OTHER=5
  String _selectedImageType = 'PHOTO';

  final List<Map<String, dynamic>> _imageTypes = [
    {'type': 'PHOTO', 'icon': Icons.photo_camera, 'label': 'PHOTO'},
    {'type': '3D', 'icon': Icons.view_in_ar, 'label': '3D'},
    {'type': 'LINE', 'icon': Icons.show_chart, 'label': 'LINE'},
    {'type': 'LOW-POLY', 'icon': Icons.filter_vintage, 'label': 'LOW-POLY'},
    {'type': 'OTHER', 'icon': Icons.more_horiz, 'label': 'OTHER'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _sourceLinkController.dispose();
    _authorController.dispose();
    _authorLinkController.dispose();
    _originalSourceController.dispose();
    super.dispose();
  }

  /// Validates URL format
  ///
  /// Returns error message if URL is invalid, null if valid or empty
  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Empty is OK (optional field)
    }

    final trimmedValue = value.trim();

    // Check if starts with http:// or https://
    if (!trimmedValue.startsWith('http://') && !trimmedValue.startsWith('https://')) {
      return AppLocalizations.of(context).invalidUrl;
    }

    // Try to parse as URI
    try {
      final uri = Uri.parse(trimmedValue);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return AppLocalizations.of(context).invalidUrl;
      }
    } catch (e) {
      return AppLocalizations.of(context).invalidUrl;
    }

    return null;
  }

  /// Maps UI image type selection to API 'style' field value
  ///
  /// API expects numeric string:
  /// - PHOTO = '1'
  /// - 3D = '2'
  /// - LINE = '3'
  /// - LOW-POLY = '4'
  /// - OTHER = '5'
  String _getStyleValue() {
    switch (_selectedImageType) {
      case 'PHOTO':
        return '1';
      case '3D':
        return '2';
      case 'LINE':
        return '3';
      case 'LOW-POLY':
        return '4';
      case 'OTHER':
        return '5';
      default:
        return '1'; // Default to PHOTO if unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).imageDetailsTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildImagePreview(),
              const SizedBox(height: 24),

              // License title field - helps identify the image
              _buildTextField(
                controller: _titleController,
                label: AppLocalizations.of(context).imageDetailsLicenseTitle,
                hint: AppLocalizations.of(context).imageDetailsLicenseTitleHint,
              ),
              const SizedBox(height: 16),

              // Source URL - where the image was found (license_object_url in API)
              _buildTextField(
                controller: _sourceLinkController,
                label: AppLocalizations.of(context).imageDetailsSourceLink,
                hint: AppLocalizations.of(context).imageDetailsSourceLinkHint,
                keyboardType: TextInputType.url,
                validator: _validateUrl,
              ),
              const SizedBox(height: 16),

              // Author name - required for proper CC BY-SA attribution
              _buildTextField(
                controller: _authorController,
                label: AppLocalizations.of(context).imageDetailsAuthor,
                hint: AppLocalizations.of(context).imageDetailsAuthorHint,
              ),
              const SizedBox(height: 16),

              // Author's website/profile URL
              _buildTextField(
                controller: _authorLinkController,
                label: AppLocalizations.of(context).imageDetailsAuthorLink,
                hint: AppLocalizations.of(context).imageDetailsAuthorLinkHint,
                keyboardType: TextInputType.url,
                validator: _validateUrl,
              ),
              const SizedBox(height: 16),

              // Original source if this is a derivative work (modified from another image)
              _buildTextField(
                controller: _originalSourceController,
                label: AppLocalizations.of(context).imageDetailsDerivativeSource,
                hint: AppLocalizations.of(context).imageDetailsDerivativeSourceHint,
                keyboardType: TextInputType.url,
                helperText: AppLocalizations.of(context).imageDetailsDerivativeHelp,
                validator: _validateUrl,
              ),
              const SizedBox(height: 24),

              _buildImageTypeSelector(),
              const SizedBox(height: 24),

              // License info as separate widget for better optimization
              const LicenseInfoWidget(),
              const SizedBox(height: 24),

              _buildButtons(),
            ],
          ),
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
          child: Image.file(widget.imageFile, fit: BoxFit.contain),
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
          children: _imageTypes.map((type) {
            final isSelected = _selectedImageType == type['type'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedImageType = type['type'];
                });
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type['icon'],
                      size: 32,
                      color: isSelected ? Colors.blue : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type['label'],
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.blue : Colors.grey.shade700,
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
          child: Text(AppLocalizations.of(context).imageDetailsCancel),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Build details map with API field names
              // Style is always included, other fields only if non-empty
              final details = <String, String>{'style': _getStyleValue()};

              // Add optional fields only if user provided values
              final title = _titleController.text.trim();
              if (title.isNotEmpty) {
                details['license_title'] = title;
              }

              final author = _authorController.text.trim();
              if (author.isNotEmpty) {
                details['license_author'] = author;
              }

              final sourceUrl = _sourceLinkController.text.trim();
              if (sourceUrl.isNotEmpty) {
                details['license_object_url'] = sourceUrl;
              }

              final authorUrl = _authorLinkController.text.trim();
              if (authorUrl.isNotEmpty) {
                details['license_author_url'] = authorUrl;
              }

              final derivativeUrl = _originalSourceController.text.trim();
              if (derivativeUrl.isNotEmpty) {
                details['license_derivative_source_url'] = derivativeUrl;
              }

              // Pass image and metadata back to parent
              widget.onAdd(widget.imageFile, details);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: Text(
            AppLocalizations.of(context).imageDetailsAdd,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}