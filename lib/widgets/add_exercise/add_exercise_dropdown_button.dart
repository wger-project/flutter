import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class AddExerciseDropdownButton extends StatefulWidget {
  AddExerciseDropdownButton({
    Key? key,
    required this.items,
    required this.title,
    required this.onChange,
  }) : super(key: key);

  final List<String> items;
  final String title;
  final ValueChanged<String?> onChange;

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
        isExpanded: true,
        onChanged: (value) {
          setState(() {
            _selectedItem = value;
          });
          widget.onChange(value);
        },
        value: _selectedItem,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          labelText: widget.title,
          alignLabelWithHint: true,
        ),
        items: widget.items
            .map(
              (item) => DropdownMenuItem<String>(
                child: Text(item),
                value: item,
              ),
            )
            .toList(),
      ),
    );
  }
}
