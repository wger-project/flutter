import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/helpers/gym_mode.dart';

class PlateWeights extends ChangeNotifier{
  List<TextEditingController> plate_weights = [TextEditingController()];
  TextEditingController bar_weight_controller = TextEditingController();
  String unit_of_plate='kg';
  bool flag=false;
  int num_inputs=1;
  num tot_weight=0;
  num c_bar=0;
  num convert_to_lbs=2.205;
  num weight_in_kg = 0;
  num bar_weight_in_kg = 0;
  List<num> weights =[0];
  List<num> custom_plates = [];
  late Map<num,int> grouped ;
  void unit_change(){
    flag=!flag;
    if(flag){
      tot_weight = weight_in_kg;
      unit_of_plate='kg';
      c_bar=bar_weight_in_kg;
    }
    else{
      unit_of_plate='lbs';
      tot_weight = weight_in_kg*2.205;
      c_bar = bar_weight_in_kg*2.205;
    }
    notifyListeners();
  }
  void addrow(){
    weights.add(0);
    num_inputs++;
    plate_weights.add(TextEditingController());
    notifyListeners();
  }
  void remove(){
    if(num_inputs>1){
      num_inputs--;
      plate_weights.removeLast;
      notifyListeners();
    }
  }
  void clear(){
    weights.clear();
    notifyListeners();
  }
  void calc(){
    weights.sort();
    custom_plates = plateCalculator(tot_weight,c_bar,weights);
    grouped =  groupPlates(custom_plates);
    for(int i=0;i<custom_plates.length;++i){
      num y = custom_plates[i];
      print("object");
      print(" | |  $y");
    }
    notifyListeners();
  }
  void printweights(){
    //print("--------------!!!!_____");
    for(int i=0;i<weights.length;++i){
      num y = weights[i];
      print("$i is $y");
      notifyListeners();
    }
  }
  void reset(){
    weights=[];
    bar_weight_controller.clear();
    bar_weight_controller=TextEditingController();
    plate_weights.clear();
    plate_weights = [TextEditingController()];
    num_inputs=1;
    notifyListeners();
  }
}