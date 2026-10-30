import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wger/core/widgets/datetime_input.dart';
import 'package:wger/core/widgets/decimal_input.dart';
import 'package:wger/features/nutrition/models/log.dart';
import 'package:wger/features/nutrition/providers/nutrition_notifier.dart';
import 'package:wger/l10n/generated/app_localizations.dart';

/// Edits a diary entry's portion and local date/time without mutating its source.
class DiaryEntryEditDialog extends ConsumerStatefulWidget {
  const DiaryEntryEditDialog({super.key, required this.entry});

  final LogItem entry;

  @override
  ConsumerState<DiaryEntryEditDialog> createState() => _DiaryEntryEditDialogState();
}

class _DiaryEntryEditDialogState extends ConsumerState<DiaryEntryEditDialog> {
  final _form = GlobalKey<FormState>();
  num? _amount;
  int? _weightUnitId;
  late DateTime _datetime;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amount = widget.entry.amount;
    _weightUnitId = widget.entry.weightUnitId;
    _datetime = widget.entry.datetime.toLocal();
  }

  Future<void> _save() async {
    final i18n = AppLocalizations.of(context);
    if (!_form.currentState!.validate()) {
      return;
    }
    final amount = _amount;
    if (amount == null || !amount.isFinite || amount != double.parse(amount.toStringAsFixed(2))) {
      setState(() => _error = i18n.enterValidNumber);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final id = widget.entry.id;
      if (id == null) {
        throw StateError('Diary entry has no id');
      }
      await ref
          .read(nutritionProvider.notifier)
          .editLog(
            id: id,
            amount: amount,
            datetime: _datetime,
            weightUnitId: _weightUnitId,
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = i18n.anErrorOccurred;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final units = {...?widget.entry.ingredient?.weightUnits};
    final originalUnit = widget.entry.weightUnitObj;
    if (originalUnit != null && !units.any((unit) => unit.id == originalUnit.id)) {
      units.add(originalUnit);
    }
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 10);
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text(i18n.edit),
        content: SingleChildScrollView(
          child: AbsorbPointer(
            absorbing: _saving,
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.entry.ingredient?.name ?? '…'),
                  DecimalInputWidget(
                    value: _amount,
                    onChanged: (value) => _amount = value,
                    labelText: i18n.amount,
                    isRequired: true,
                    min: 1,
                    max: 1000,
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        key: const Key('diary-edit-grams'),
                        label: Text(i18n.g),
                        selected: _weightUnitId == null,
                        onSelected: (_) => setState(() => _weightUnitId = null),
                      ),
                      for (final unit in units)
                        ChoiceChip(
                          label: Text('${unit.name} (${i18n.gValue(unit.grams.toString())})'),
                          selected: _weightUnitId == unit.id,
                          onSelected: (_) => setState(() => _weightUnitId = unit.id),
                        ),
                      if (_weightUnitId != null && !units.any((unit) => unit.id == _weightUnitId))
                        Chip(label: Text('${i18n.weightUnit}: …')),
                    ],
                  ),
                  DateInputWidget(
                    value: _datetime,
                    labelText: i18n.date,
                    firstDate: _datetime.isBefore(firstDate) ? _datetime : firstDate,
                    lastDate: _datetime.isAfter(now) ? _datetime : now,
                    onChanged: (date) => setState(() {
                      _datetime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        _datetime.hour,
                        _datetime.minute,
                      );
                    }),
                  ),
                  TimeInputWidget(
                    value: TimeOfDay.fromDateTime(_datetime),
                    labelText: i18n.time,
                    onChanged: (time) => setState(() {
                      _datetime = DateTime(
                        _datetime.year,
                        _datetime.month,
                        _datetime.day,
                        time.hour,
                        time.minute,
                      );
                    }),
                  ),
                  if (_error != null)
                    Text(
                      _error!,
                      key: const Key('diary-edit-error'),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            key: const Key('diary-edit-cancel'),
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            key: const Key('diary-edit-save'),
            onPressed: _saving ? null : _save,
            child: Text(i18n.save),
          ),
        ],
      ),
    );
  }
}
