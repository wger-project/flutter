import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wger/providers/exercises.dart';

import 'filter_modal.dart';

class FilterRow extends StatefulWidget {
  FilterRow({Key? key}) : super(key: key);

  @override
  _FilterRowState createState() => _FilterRowState();
}

class _FilterRowState extends State<FilterRow> {
  late final TextEditingController _exerciseNameController;

  @override
  void initState() {
    super.initState();

    _exerciseNameController = TextEditingController()
      ..addListener(
        () {
          final provider = Provider.of<ExercisesProvider>(context, listen: false);
          if (provider.filters!.searchTerm != _exerciseNameController.text) {
            provider
                .setFilters(provider.filters!.copyWith(searchTerm: _exerciseNameController.text));
          }
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _exerciseNameController,
            decoration: InputDecoration(
              hintText: '${AppLocalizations.of(context).exerciseName}...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search),
            ),
            IconButton(
              onPressed: () async {
                showModalBottomSheet<Filters>(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => ExerciseFilterModalBody(),
                );
              },
              icon: Icon(Icons.filter_alt),
            ),
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }
}
