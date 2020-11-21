import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/models/body_weight/weight_entry.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/widgets/app_drawer.dart';
import 'package:wger/widgets/weight/entries_list.dart';

class WeightScreen extends StatelessWidget {
  static const routeName = '/weight';

  Future<void> _refreshWeightEntries(BuildContext context) async {
    await Provider.of<BodyWeight>(context, listen: false).fetchAndSetEntries();
  }

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<BodyWeight>(context, listen: false).addEntry(
            WeightEntry(
              date: DateTime.now(),
              weight: 80,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _refreshWeightEntries(context),
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _refreshWeightEntries(context),
                child: Consumer<BodyWeight>(
                  builder: (context, productsData, child) => WeightEntriesList(),
                ),
              ),
      ),
    );
  }
}
