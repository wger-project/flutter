import 'package:flutter/material.dart';
import 'package:wger/locale/locales.dart';
import 'package:wger/models/workouts/day.dart';
import 'package:wger/models/workouts/set.dart';
import 'package:wger/models/workouts/setting.dart';

class SettingWidget extends StatelessWidget {
  Setting setting;

  SettingWidget({this.setting});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        child: setting.exercise.images.length > 0
            ? FadeInImage(
                placeholder: AssetImage('assets/images/placeholder.png'),
                image: NetworkImage(setting.exercise.getMainImage.url),
                fit: BoxFit.cover,
              )
            : Image(
                image: AssetImage('assets/images/placeholder.png'),
                color: Color.fromRGBO(255, 255, 255, 0.3),
                colorBlendMode: BlendMode.modulate),
        width: 45,
      ),
      title: Text(setting.exercise.name),
      subtitle: Text(setting.repsText),
    );
  }
}

class WorkoutDayWidget extends StatelessWidget {
  Day _day;

  WorkoutDayWidget(this._day);

  // Form stuff
  final GlobalKey<FormState> _formKey = GlobalKey();
  final exercisesController = TextEditingController();

  Widget getSetRow(Set set) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        Text('#${set.order}'),
        Expanded(
          child: Column(children: [
            ...set.settings
                .map(
                  (setting) => SettingWidget(setting: setting),
                )
                .toList(),
            Divider(),
          ]),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.black12),
            padding: const EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  _day.description,
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text(_day.getDaysText),
              ],
            ),
          ),
          ..._day.sets
              .map(
                (set) => getSetRow(set),
              )
              .toList(),
          OutlinedButton(
            child: Text('Add exercise to day'),
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SetFormWidget(
                        formKey: _formKey, exercisesController: exercisesController);
                  });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
          )
        ],
      ),
    );
  }
}

class SetFormWidget extends StatefulWidget {
  const SetFormWidget({
    Key key,
    @required GlobalKey<FormState> formKey,
    @required this.exercisesController,
  })  : _formKey = formKey,
        super(key: key);

  final GlobalKey<FormState> _formKey;
  final TextEditingController exercisesController;

  @override
  _SetFormWidgetState createState() => _SetFormWidgetState();
}

class _SetFormWidgetState extends State<SetFormWidget> {
  double _currentSetSliderValue = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: widget._formKey,
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context).newSet,
              style: Theme.of(context).textTheme.headline6,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Exercise IDs, comma separated (TODO: autocompleter)',
              ),
              controller: widget.exercisesController,
              onSaved: (value) {
                print(value);
              },
            ),
            Text('Number of sets:'),
            Slider(
              value: _currentSetSliderValue,
              min: 1,
              max: 10,
              divisions: 10,
              label: _currentSetSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSetSliderValue = value;
                });
              },
            ),
            ElevatedButton(child: Text('Save'), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
