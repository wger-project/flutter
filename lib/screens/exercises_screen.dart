import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/exercises/filter_modal.dart';
import 'package:wger/widgets/exercises/list_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({Key? key}) : super(key: key);
  static const routeName = '/exercises';

  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late final TextEditingController _exerciseNameController;

  @override
  void initState() {
    super.initState();
    Provider.of<ExercisesProvider>(context, listen: false).initFilters();
    _exerciseNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesList = Provider.of<ExercisesProvider>(context, listen: false).findByFilters();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: WgerAppBar(AppLocalizations.of(context).exercises),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
            child: Row(
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
                        await showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => ExerciseFilterModalBody(),
                        );

                        final filters = Provider.of<ExercisesProvider>(
                          context,
                          listen: false,
                        ).filters!;

                        if (filters.doesNeedUpdate) {
                          setState(() {
                            filters.markUpdated();
                          });
                        }
                      },
                      icon: Icon(Icons.filter_alt),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 1,
                );
              },
              itemCount: exercisesList.length,
              itemBuilder: (context, index) {
                final exercise = exercisesList[index];
                return Container(
                  height: size.height * 0.175,
                  child: ExerciseListTile(exercise: exercise),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }
}
