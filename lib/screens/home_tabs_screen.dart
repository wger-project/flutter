import 'package:flutter/material.dart';
import 'package:wger/screens/nutrition_screen.dart';
import 'package:wger/screens/schedule_screen.dart';
import 'package:wger/screens/weight_screen.dart';

class HomeTabsScreen extends StatefulWidget {
  @override
  _HomeTabsScreenState createState() => _HomeTabsScreenState();
}

class _HomeTabsScreenState extends State<HomeTabsScreen> {
  List<Map<String, Object>> _pages;

  @override
  initState() {
    _pages = [
      {'page': ScheduleScreen(), 'title': 'Schedule'},
      {'page': NutritionScreen(), 'title': 'Nutrition'},
      {'page': WeightScreen(), 'title': 'Weight'},
    ];
    super.initState();
  }

  int _selectedPageIndex = 0;
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.black87,
        currentIndex: _selectedPageIndex,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.fastfood),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.bar_chart),
            label: 'Weight',
          )
        ],
      ),
    );
  }
}
