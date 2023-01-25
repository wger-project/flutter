import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/add_exercise.dart';

class AddExerciseHtmlEditor extends StatefulWidget {
  const AddExerciseHtmlEditor({
    Key? key,
    this.helperText = '',
  }) : super(key: key);

  final String helperText;

  @override
  _AddExerciseHtmlEditorState createState() => _AddExerciseHtmlEditorState();
}

class _AddExerciseHtmlEditorState extends State<AddExerciseHtmlEditor> {
  @override
  Widget build(BuildContext context) {
    final addExerciseProvider = context.read<AddExerciseProvider>();
    final HtmlEditorController editorController = HtmlEditorController(
        processInputHtml: true,
        processNewLineAsBr: false,
        processOutputHtml: true
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: HtmlEditor(
        controller: editorController,
        htmlToolbarOptions: const HtmlToolbarOptions(
            toolbarPosition: ToolbarPosition.belowEditor,
            toolbarType: ToolbarType.nativeScrollable,
            defaultToolbarButtons: [
              FontButtons(bold: true,
                  underline: true,
                  italic: true,
                  strikethrough: false,
                  superscript: false,
                  subscript: false,
                  clearAll: false
              ),
              ListButtons(
                  ol: true,
                  ul: true,
                  listStyles: false
              ),
              ParagraphButtons(
                  textDirection: false,
                  lineHeight: false,
                  caseConverter: false,
                  increaseIndent: false,
                  decreaseIndent: false,
                  alignLeft: false,
                  alignCenter: false,
                  alignRight: false,
                  alignJustify: false
              ),
            ]
        ),
        htmlEditorOptions: HtmlEditorOptions(
          hint: widget.helperText,
          shouldEnsureVisible: true,
        ),
        otherOptions: const OtherOptions(
          height: 200,
        ),
        callbacks: Callbacks(onChangeContent: (String? currentHtml) {
          addExerciseProvider.descriptionEn = currentHtml!;
        },
        ),
      ),
    );
  }
}
