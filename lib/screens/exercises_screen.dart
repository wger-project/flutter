import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/exercises/category.dart';
import 'package:wger/providers/exercises.dart';
import 'package:wger/widgets/core/app_bar.dart';
import 'package:wger/widgets/exercises/list_tile.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({Key? key}) : super(key: key);
  static const routeName = '/exercises';

  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  ExerciseCategory? _category;

  List<DropdownMenuItem<ExerciseCategory>> _categoryOptions() {
    return Provider.of<ExercisesProvider>(context, listen: false)
        .categories
        .map<DropdownMenuItem<ExerciseCategory>>(
      (category) {
        return DropdownMenuItem<ExerciseCategory>(
          child: Text(category.name),
          value: category,
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesList =
        Provider.of<ExercisesProvider>(context, listen: false).findByCategory(_category);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: WgerAppBar('Exercises'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ExerciseCategory>(
                    hint: Text('All Exercises'),
                    value: _category,
                    items: _categoryOptions(),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                    onChanged: (ExerciseCategory? newCategory) {
                      setState(() {
                        _category = newCategory;
                      });
                    },
                  ),
                ),
                Row(
                  children: [
                    IconButton(onPressed: () {}, icon: Icon(Icons.search)),
                    IconButton(onPressed: () {}, icon: Icon(Icons.filter_alt)),
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
}
