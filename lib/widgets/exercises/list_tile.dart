import 'package:flutter/material.dart';
import 'package:wger/models/exercises/exercise.dart';
import 'package:wger/widgets/exercises/images.dart';

class ExerciseListTile extends StatelessWidget {
  const ExerciseListTile({Key? key, required this.exercise}) : super(key: key);

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return ListTile(
      leading:
      CircleAvatar(
        backgroundColor: const Color(0x00ffffff),
        child: ClipOval(
          child: SizedBox(
            height: 40,
            width: 40,
            child: ExerciseImageWidget(
              image: exercise.getMainImage,
            ),
          ),
        ),
      ),

      title: Text(
        exercise.name,
        //style: theme.textTheme.headline6,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: Text(
        exercise.category.name,
      ),
      /*
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: theme.primaryColorLight.withOpacity(0.15),
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          exercise.category.name,
        ),
      ),

       */
    );

    /*
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: size.width * 0.2,
            child: Center(
              child: ExerciseImageWidget(
                image: exercise.getMainImage,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: theme.primaryColorLight.withOpacity(0.15),
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  exercise.category.name,
                ),
              ),
              Text(
                exercise.name,
                style: theme.textTheme.headline6,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              Text(
                exercise.equipment.map((equipment) => equipment.name).join(", "),
              )
            ],
          ),
        )
      ],
    );

     */
  }
}
