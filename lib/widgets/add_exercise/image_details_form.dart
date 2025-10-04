import 'dart:io';
import 'package:flutter/material.dart';

/// Form for collecting image metadata including license information
///
/// Displayed after image selection in Step 5 of exercise creation
/// Collects: title, source URL, author info, derivative work info, and image style
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

  final _titleController = TextEditingController();
  final _sourceLinkController = TextEditingController();
  final _authorController = TextEditingController();
  final _authorLinkController = TextEditingController();
  final _originalSourceController = TextEditingController();

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

  /// Maps UI image type selection to API style value
  /// PHOTO=1, 3D=2, LINE=3, LOW-POLY=4, OTHER=5
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
        return '1';
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
                'Image details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildImagePreview(),
              const SizedBox(height: 24),

              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter image title',
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _sourceLinkController,
                label: 'Link to the source website, if available',
                hint: 'https://example.com',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _authorController,
                label: 'Author(s)',
                hint: 'Enter author name',
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _authorLinkController,
                label: 'Link to author website or profile, if available',
                hint: 'https://example.com/author',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _originalSourceController,
                label: 'Link to the original source, if this is a derivative work',
                hint: 'https://example.com/original',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 8),

              _buildDerivativeWorkNote(),
              const SizedBox(height: 24),

              _buildImageTypeSelector(),
              const SizedBox(height: 24),

              _buildLicenseInfo(),
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
        constraints: const BoxConstraints(
          maxWidth: 300,
          maxHeight: 200,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            widget.imageFile,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// Info box explaining what constitutes a derivative work
  Widget _buildDerivativeWorkNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Note that a derivative work is one which is not only based on a previous work, but which also contains sufficient new, creative content to entitle it to its own copyright.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Selector for image style (PHOTO, 3D, LINE, LOW-POLY, OTHER)
  Widget _buildImageTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
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

  /// Warning box about CC BY-SA 4.0 license requirements
  Widget _buildLicenseInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Colors.amber.shade900,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber.shade900,
                ),
                children: const [
                  TextSpan(
                    text: 'By submitting this image, you agree to release it under the ',
                  ),
                  TextSpan(
                    text: 'CC BY-SA 4.0',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(
                    text: ' license. The image must be either your own work or the author must have released it under a license compatible with CC BY-SA 4.0.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('CANCEL'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Build details map with API field names
              final details = <String, String>{
                'style': _getStyleValue(),
              };

              // Add only non-empty fields
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

              widget.onAdd(widget.imageFile, details);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 12,
            ),
          ),
          child: const Text(
            'ADD',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}