/*
 * This file is part of wger Workout Manager <https://github.com/wger-project>.
 * Copyright (c)  2026 wger Team
 *
 * wger Workout Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;

class AddExerciseTextArea extends StatelessWidget {
  final ValueChanged<String> onChange;
  final bool isMultiline;
  final String title;
  final String helperText;
  final String? initialValue;
  final bool useMarkdownEditor;
  final FormFieldValidator<String?>? validator;
  final FormFieldSetter<String?>? onSaved;

  AddExerciseTextArea({
    super.key,
    required this.title,
    ValueChanged<String>? onChange,
    this.helperText = '',
    this.isMultiline = false,
    this.useMarkdownEditor = false,
    this.initialValue = '',
    this.validator,
    this.onSaved,
  }) : onChange = onChange ?? ((String value) {});

  static const MULTILINE_MIN_LINES = 4;
  static const DEFAULT_LINES = 1;

  @override
  Widget build(BuildContext context) {
    if (useMarkdownEditor) {
      return MarkdownEditor(
        initialValue: initialValue ?? '',
        onChanged: onChange,
        validator: validator,
        onSaved: onSaved,
        helperText: helperText,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: isMultiline ? TextInputType.multiline : TextInputType.text,
        maxLines: isMultiline ? null : DEFAULT_LINES,
        minLines: isMultiline ? MULTILINE_MIN_LINES : DEFAULT_LINES,
        validator: validator,
        onSaved: onSaved,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          labelText: title,
          alignLabelWithHint: true,
          helperText: helperText,
          helperMaxLines: 3,
        ),
        onChanged: onChange,
      ),
    );
  }
}

/// Lightweight Markdown editor with a small toolbar and a raw Markdown toggle.
///
/// Designed for small documents with basic formatting (bold/italic/code).
/// No image or link insertion is provided.
class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({
    super.key,
    this.initialValue = '',
    required this.onChanged,
    this.validator,
    this.onSaved,
    this.readOnly = false,
    this.showToolbar = true,
    this.helperText = '',
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String?>? validator;
  final FormFieldSetter<String?>? onSaved;
  final bool readOnly;
  final bool showToolbar;
  final String helperText;

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    // Notify parent and rebuild preview on every controller change.
    _controller.addListener(() {
      widget.onChanged(_controller.text);
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant MarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _surroundSelection(String left, String right) {
    final sel = _controller.selection;
    final full = _controller.text;
    final start = sel.start < 0 ? 0 : sel.start;
    final end = sel.end < 0 ? 0 : sel.end;
    final before = full.substring(0, start);
    final selected = full.substring(start, end);
    final after = full.substring(end);

    final newText = '$before$left$selected$right$after';
    _controller.text = newText;

    final cursorPos = start + left.length + selected.length + right.length;
    _controller.selection = TextSelection.collapsed(offset: cursorPos);
  }

  Widget _buildToolbar() {
    if (!widget.showToolbar || widget.readOnly) return const SizedBox.shrink();
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.format_bold),
          tooltip: 'Bold',
          onPressed: () => _surroundSelection('**', '**'),
        ),
        IconButton(
          icon: const Icon(Icons.format_italic),
          tooltip: 'Cursive',
          onPressed: () => _surroundSelection('*', '*'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab bar (Edit / Preview)
            TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
              tabs: const [
                Tab(text: 'Edit'),
                Tab(text: 'Preview'),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: TabBarView(
                children: [
                  // Edit tab: toolbar + editor
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.showToolbar) _buildToolbar(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _controller,
                          maxLines: null,
                          minLines: 6,
                          validator: widget.validator,
                          onSaved: widget.onSaved,
                          decoration: InputDecoration(
                            hintText: 'You can use basic Markdown formatting here',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            helperText: widget.helperText,
                            helperMaxLines: 3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Preview tab: rendered HTML
                  Container(
                    constraints: const BoxConstraints(minHeight: 120),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withAlpha((0.08 * 255).round()),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: SingleChildScrollView(
                      child: Builder(
                        builder: (ctx) {
                          final raw = _controller.text;
                          final html = md.markdownToHtml(raw);
                          if (html.trim().isEmpty) {
                            return SelectableText(raw.isEmpty ? '(empty)' : raw);
                          }
                          return Html(data: html);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
