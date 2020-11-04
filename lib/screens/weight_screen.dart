import 'package:flutter/material.dart';
import 'package:wger/widgets/app_drawer.dart';

class WeightScreen extends StatelessWidget {
  Widget getAppBar() {
    return AppBar(
      title: Text('Weight'),
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
      drawer: AppDrawer(),
    );
  }
}
