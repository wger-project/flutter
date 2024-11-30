import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wger/helpers/gym_mode.dart';

class PlateWeights extends ChangeNotifier{
  List<TextEditingController> plate_weights = [TextEditingController()];
  TextEditingController bar_weight_controller = TextEditingController();
  String unit_of_plate='kg';
  bool flag=false;
  int num_inputs=1;
  num tot_weight=0;
  num c_bar=20;
  num convert_to_lbs=2.205;
  num weight_in_kg = 0;
  num bar_weight_in_kg = 20;
  List<num> selected_weights=[];
  List<num> kg_weights = [1.25, 2.5, 5, 10, 15, 20,25];
  List<num> lbs_weights=[2.5, 5, 10, 25, 35,45];
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
  void toggle_selection(num x){
    if(unit_of_plate=="kg"){
      if(selected_weights.contains(x))
        selected_weights.remove(x);
      else
        selected_weights.add(x);
    }else{
      if(selected_weights.contains(x))
        selected_weights.remove(x);
      else
        selected_weights.add(x);
    }
    notifyListeners();
  }
  
  
  void clear(){
    selected_weights.clear();
    notifyListeners();
  }
  void set_weight(num x){
    tot_weight=x;
    weight_in_kg=x;
    notifyListeners();
  }
  void calc(){
    selected_weights.sort();
    custom_plates = plateCalculator(tot_weight,c_bar,selected_weights);
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
    for(int i=0;i<selected_weights.length;++i){
      num y = selected_weights[i];
      print("$i is $y");
      notifyListeners();
    }
  }
  void reset(){
    selected_weights=[];
    notifyListeners();
  }
  // void reset(){
  //   selected_weights=[];
  //   bar_weight_controller.clear();
  //   bar_weight_controller=TextEditingController();
  //   plate_weights.clear();
  //   plate_weights = [TextEditingController()];
  //   num_inputs=1;
  //   notifyListeners();
  // }

}