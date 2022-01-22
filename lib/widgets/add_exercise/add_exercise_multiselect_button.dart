import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddExerciseMultiselectButton extends StatefulWidget {
  AddExerciseMultiselectButton({
    Key? key,
    required this.items,
    required this.title,
    required this.onChange,
    this.onSaved,
  }) : super(key: key);

  final List<String> items;
  final String title;
  final ValueChanged<List<String?>> onChange;
  final FormFieldSetter<List<String?>?>? onSaved;

  @override
  _AddExerciseMultiselectButtonState createState() => _AddExerciseMultiselectButtonState();
}

class _AddExerciseMultiselectButtonState extends State<AddExerciseMultiselectButton> {
  List<String?> _selectedItems = [];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MultiSelectDialogField<String?>(
        onSaved: widget.onSaved,
        items: widget.items.map((item) => MultiSelectItem<String?>(item, item)).toList(),
        onConfirm: (value) {
          setState(() {
            _selectedItems = value;
            widget.onChange(_selectedItems);
          });
        },
        chipDisplay: MultiSelectChipDisplay<String?>(
          scroll: true,
          onTap: (value) {
            setState(() {
              _selectedItems.remove(value);
              widget.onChange(_selectedItems);
            });
          },
          icon: Icon(Icons.close),
        ),
        title: Text(widget.title),
        buttonText: Text(
          widget.title,
          style: TextStyle(color: _selectedItems.length == 0 ? Colors.grey[700] : Colors.grey),
        ),
        buttonIcon: Icon(Icons.arrow_drop_down,
            color: _selectedItems.length == 0 ? Colors.grey[700] : Colors.grey),
        decoration: BoxDecoration(
          border: Border.all(color: _selectedItems.length == 0 ? Colors.grey : Colors.transparent),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    );
  }
}
