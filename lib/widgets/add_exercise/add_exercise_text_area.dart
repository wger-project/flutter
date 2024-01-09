import 'package:flutter/material.dart';

class AddExerciseTextArea extends StatelessWidget {
  const AddExerciseTextArea({
    super.key,
    required this.onChange,
    required this.title,
    this.helperText = '',
    this.isRequired = true,
    this.isMultiline = false,
    this.validator,
    this.onSaved,
  });

  final ValueChanged<String> onChange;
  final bool isRequired;
  final bool isMultiline;
  final String title;
  final String helperText;
  final FormFieldValidator<String?>? validator;
  final FormFieldSetter<String?>? onSaved;

  static const MULTILINE_MIN_LINES = 4;
  static const DEFAULT_LINES = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: isMultiline ? TextInputType.multiline : TextInputType.text,
        maxLines: isMultiline ? null : DEFAULT_LINES,
        minLines: isMultiline ? MULTILINE_MIN_LINES : DEFAULT_LINES,
        validator: validator,
        onSaved: onSaved,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          labelText: title,
          alignLabelWithHint: true,
          helperText: helperText,
        ),
        onChanged: onChange,
      ),
    );
  }
}
