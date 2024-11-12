import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/routine.dart';
import 'package:wger/providers/routines.dart';

class DayFormWidget extends StatefulWidget {
  final Routine routine;
  final dayController = TextEditingController();
  late final Day _day;

  DayFormWidget(this.routine, [Day? day]) {
    _day = day ?? Day();
    _day.routineId = routine.id!;
    if (_day.id != null) {
      dayController.text = day!.description;
    }
  }

  @override
  _DayFormWidgetState createState() => _DayFormWidgetState();
}

class _DayFormWidgetState extends State<DayFormWidget> {
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: ListView(
        children: [
          TextFormField(
            key: const Key('field-description'),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).description,
              helperText: AppLocalizations.of(context).dayDescriptionHelp,
              helperMaxLines: 3,
            ),
            controller: widget.dayController,
            onSaved: (value) {
              widget._day.description = value!;
            },
            validator: (value) {
              const minLength = 1;
              const maxLength = 100;
              if (value!.isEmpty || value.length < minLength || value.length > maxLength) {
                return AppLocalizations.of(context).enterCharacters(minLength, maxLength);
              }

              return null;
            },
          ),
          // const SizedBox(height: 10),
          // ...Day.weekdays.keys.map((dayNr) => DayCheckbox(dayNr, widget._day)),
          ElevatedButton(
            key: const Key(SUBMIT_BUTTON_KEY_NAME),
            child: Text(AppLocalizations.of(context).save),
            onPressed: () async {
              if (!_form.currentState!.validate()) {
                return;
              }
              _form.currentState!.save();

              try {
                if (widget._day.id == null) {
                  Provider.of<RoutinesProvider>(context, listen: false).addDay(
                    widget._day,
                    widget.routine,
                  );
                } else {
                  Provider.of<RoutinesProvider>(context, listen: false).editDay(
                    widget._day,
                  );
                }

                widget.dayController.clear();
                Navigator.of(context).pop();
              } catch (error) {
                await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('An error occurred!'),
                    content: const Text('Something went wrong.'),
                    actions: [
                      TextButton(
                        child: const Text('Okay'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
