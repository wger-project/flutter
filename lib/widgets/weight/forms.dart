import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/json.dart';
import 'package:wger/helpers/ui.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/models/http_exception.dart';
import 'package:wger/providers/body_weight.dart';

class WeightForm extends StatelessWidget {
  final _form = GlobalKey<FormState>();
  final dateController = TextEditingController(text: toDate(DateTime.now()).toString());
  final weightController = TextEditingController();

  late WeightEntry _weightEntry;

  WeightForm([WeightEntry? weightEntry]) {
    this._weightEntry = weightEntry ?? WeightEntry();
    weightController.text = _weightEntry.id == null ? '' : _weightEntry.weight.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: [
          // Weight date
          TextFormField(
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.date),
            controller: dateController,
            onTap: () async {
              // Stop keyboard from appearing
              FocusScope.of(context).requestFocus(new FocusNode());

              // Show Date Picker Here
              var pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(DateTime.now().year - 10),
                lastDate: DateTime.now(),
              );

              dateController.text = toDate(pickedDate)!;
            },
            onSaved: (newValue) {
              _weightEntry.date = DateTime.parse(newValue!);
            },
            onFieldSubmitted: (_) {},
          ),

          // Weight
          TextFormField(
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.weight),
            controller: weightController,
            keyboardType: TextInputType.number,
            onFieldSubmitted: (_) {},
            onSaved: (newValue) {
              _weightEntry.weight = double.parse(newValue!);
            },
            validator: (value) {
              if (value!.isEmpty) {
                return AppLocalizations.of(context)!.enterValue;
              }
              try {
                double.parse(value);
              } catch (error) {
                return AppLocalizations.of(context)!.enterValidNumber;
              }
              return null;
            },
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.save),
            onPressed: () async {
              // Validate and save the current values to the weightEntry
              final isValid = _form.currentState!.validate();
              if (!isValid) {
                return;
              }
              _form.currentState!.save();

              // Save the entry on the server
              try {
                _weightEntry.id == null
                    ? await Provider.of<BodyWeight>(context, listen: false).addEntry(_weightEntry)
                    : await Provider.of<BodyWeight>(context, listen: false).editEntry(_weightEntry);
              } on WgerHttpException catch (error) {
                showHttpExceptionErrorDialog(error, context);
              } catch (error) {
                showErrorDialog(error, context);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
