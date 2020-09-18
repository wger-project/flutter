import 'package:flutter/material.dart';

class WorkoutsScreen extends StatelessWidget {
  Widget getAppBar() {
    return AppBar(
      title: Text('Workouts'),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
    );
  }
}
