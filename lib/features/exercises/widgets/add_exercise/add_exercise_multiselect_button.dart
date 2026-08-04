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
    final scheme = Theme.of(context).colorScheme;
    // Dimmed once something is selected: the chips below carry the content and
    // the title drops back to a caption.
    final labelColor = _selectedItems.isEmpty ? scheme.onSurfaceVariant : scheme.outline;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MultiSelectDialogField(
        initialValue: widget.initialItems,
        onSaved: widget.onSaved,
        items: widget.items
            .map((item) => MultiSelectItem<T>(item, widget.displayName(item)))
            .toList(),
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
        buttonText: Text(widget.title, style: TextStyle(color: labelColor)),
        buttonIcon: Icon(Icons.arrow_drop_down, color: labelColor),
        decoration: BoxDecoration(
          // Once chips carry the selection the outline is dropped, the same way
          // a filled input field loses its placeholder framing.
          border: Border.all(
            color: _selectedItems.isEmpty ? scheme.outline : Colors.transparent,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
