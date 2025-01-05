import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wger/helpers/gym_mode.dart';

class PlateWeights extends ChangeNotifier{
  bool isMetric = true;
  bool plateChoiceExists = false;
  bool loadedFromSharedPref = false;
  num totalWeight = 0;
  num barWeight = 20;
  num convertTolbs = 2.205;
  num totalWeightInKg = 0;
  num barWeightInKg = 20;
  List<num> selectedWeights = [];
  List<num> kgWeights = [1.25, 2.5, 5, 10, 15, 20, 25];
  List<num> lbsWeights = [2.5, 5, 10, 25, 35, 45];
  List<num> customPlates = [];
  late Map<num,int> grouped;
  List<num> get data => selectedWeights;
  set data(List<num> newData){
    selectedWeights = newData;
    //saving data to shared preference
    saveIntoSharedPrefs();
    notifyListeners();
  }
  Future<void> saveIntoSharedPrefs() async{
    final pref = await SharedPreferences.getInstance();
    //converting List Weights to String
    final String selectedPlates = jsonEncode(selectedWeights);
    pref.setString('selectedPlates', selectedPlates);
    notifyListeners();
  }

  void readPlates() async{
    final pref = await SharedPreferences.getInstance();
    final platePrefData = pref.getString('selectedPlates');
    if(platePrefData != null){
        try{
            final plateData = json.decode(platePrefData);
            if(plateData is List){
              selectedWeights = plateData.cast<num>();
            }else{
              throw const FormatException('Not a List');
            }
        }catch(e){
          selectedWeights = [];
        }
    }
    print('loaded');
    notifyListeners();
  }

  Future<void> toggleSelection(num x) async{
    if(selectedWeights.contains(x)) {
      selectedWeights.remove(x);
    }else {
      selectedWeights.add(x);
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedPlates',jsonEncode(selectedWeights));
    notifyListeners();
  }

  void unitChange() {
    if(isMetric==false) {
      totalWeight = totalWeightInKg;
      isMetric = true;
      barWeight = barWeightInKg;
    } else {
      isMetric = false;
      totalWeight = totalWeightInKg*2.205;
      barWeight = barWeightInKg*2.205;
    }
    notifyListeners();
  }

  void clear() async{
    selectedWeights.clear();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedPlates',jsonEncode(selectedWeights));
    notifyListeners();
  }

  void setWeight(num x) {
    totalWeight = x;
    totalWeightInKg=x;
    notifyListeners();
  }

  void calculatePlates() {
    selectedWeights.sort();
    customPlates = plateCalculator(totalWeight,barWeight,selectedWeights);
    grouped =  groupPlates(customPlates);
    notifyListeners();
  }

  void resetPlates() async{
    selectedWeights = [];
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedPlates',jsonEncode(selectedWeights));
    notifyListeners();
  }
  
}  