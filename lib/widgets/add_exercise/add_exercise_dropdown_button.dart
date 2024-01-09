import 'package:flutter/material.dart';

class AddExerciseDropdownButton extends StatefulWidget {
  const AddExerciseDropdownButton({
    super.key,
    required this.items,
    required this.title,
    required this.onChange,
    this.validator,
    this.onSaved,
  });

  final List<String> items;
  final String title;
  final ValueChanged<String?> onChange;
  final FormFieldValidator<String?>? validator;
  final FormFieldSetter<String?>? onSaved;

  @override
  _AddExerciseDropdownButtonState createState() => _AddExerciseDropdownButtonState();
}

class _AddExerciseDropdownButtonState extends State<AddExerciseDropdownButton> {
  String? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        validator: widget.validator,
        isExpanded: true,
        onSaved: widget.onSaved,
        onChanged: (value) {
          setState(() {
            _selectedItem = value;
          });
          widget.onChange(value);
        },
        value: _selectedItem,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          labelText: widget.title,
          alignLabelWithHint: true,
        ),
        items: widget.items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
      ),
    );
  }
}
