import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddExerciseMultiselectButton<T> extends StatefulWidget {
  final List<T> items;
  final List<T> initialItems;
  final String title;
  final ValueChanged<List<T?>> onChange;
  final FormFieldSetter<List<T?>?>? onSaved;
  final Function displayName;

  const AddExerciseMultiselectButton({
    super.key,
    required this.items,
    required this.title,
    required this.onChange,
    this.initialItems = const [],
    this.onSaved,
    required this.displayName,
  });

  @override
  _AddExerciseMultiselectButtonState createState() => _AddExerciseMultiselectButtonState<T>();
}

class _AddExerciseMultiselectButtonState<T> extends State<AddExerciseMultiselectButton> {
  List<T> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MultiSelectDialogField(
        initialValue: widget.initialItems,
        onSaved: widget.onSaved,
        items:
            widget.items.map((item) => MultiSelectItem<T>(item, widget.displayName(item))).toList(),
        onConfirm: (value) {
          setState(() {
            _selectedItems = value.cast<T>();
            widget.onChange(_selectedItems);
          });
        },
        chipDisplay: MultiSelectChipDisplay(
          //scroll: true,
          onTap: (value) {
            setState(() {
              _selectedItems.remove(value);
              widget.onChange(_selectedItems);
            });
          },
          icon: const Icon(Icons.close),
        ),
        title: Text(widget.title),
        buttonText: Text(
          widget.title,
          style: TextStyle(
            color: _selectedItems.isEmpty ? Colors.grey[700] : Colors.grey,
          ),
        ),
        buttonIcon: Icon(
          Icons.arrow_drop_down,
          color: _selectedItems.isEmpty ? Colors.grey[700] : Colors.grey,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedItems.isEmpty ? Colors.grey : Colors.transparent,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
