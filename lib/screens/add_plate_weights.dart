import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/plate_weights.dart';

class AddPlateWeights extends StatefulWidget {
  const AddPlateWeights({super.key});

  @override
  State<AddPlateWeights> createState() => _AddPlateWeightsState();
}

class _AddPlateWeightsState extends State<AddPlateWeights> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlateWeights>(
      builder:(context,plate_provider,child)=> Scaffold(
        
        appBar: AppBar(
          title: Text('Enter Custom Plate Weights!!!'),
        ),
        body: 

        Column(
          children: [
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Kg or lbs'),
                DropdownButton(
                  onChanged: (newValue){
                  plate_provider.clear();
                  plate_provider.unit_change();
                  plate_provider.unit_of_plate=newValue!;   
                }, items: ["kg","lbs"].map((unit){
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
                }).toList(),
              ),
            ],  
          ),
        

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: plate_provider.unit_of_plate == "kg"
                  ? plate_provider.kg_weights.map((number) {
                      return GestureDetector(
                        onTap: () => plate_provider.toggle_selection(number),
                        child: Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: plate_provider.selected_weights.contains(number)
                                ? const Color.fromARGB(255, 82, 226, 236)
                                : const Color.fromARGB(255, 97, 105, 101),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$number kg', // Add unit to text
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList()
                  : plate_provider.lbs_weights.map((number) {
                      return GestureDetector(
                        onTap: () => plate_provider.toggle_selection(number),
                        child: Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: plate_provider.selected_weights.contains(number)
                                ? const Color.fromARGB(255, 82, 226, 236)
                                : const Color.fromARGB(255, 97, 105, 101),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$number lbs', // Add unit to text
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                      onPressed: (){
                        if(plate_provider.selected_weights.length>=1){
                          plate_provider.flag=true;
                        plate_provider.calc();}
                        print("object");
                        print(plate_provider.selected_weights.length);
                        Navigator.pop(context);
                      },
                      child: Text('Done'),
                    ),
                ElevatedButton(
                  onPressed: (){
                    plate_provider.reset();
                  }, 
                  child: Text("Reset",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold))
                ),
            ],
          ),
          ]
        ),
      ),
    );
  }
}

// SingleChildScrollView(
        //   child: Column(
        //     children: [
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Text('Kg or lbs'),
        //             DropdownButton(
        //                 onChanged: (newValue){
        //                   plate_provider.unit_change();
        //                   plate_provider.unit_of_plate=newValue!;  
        //                 }, items: ["kg","lbs"].map((unit){
        //                   return DropdownMenuItem<String>(
        //                     value: unit,
        //                     child: Text(unit),
        //                   );
        //                 }).toList(),
        //       ),
        //     ],
            
        //   ),
        //   //Text('Enter Bar Weight:-',style: TextStyle(fontSize: 20),),
          
        //   TextField(
        //     controller: plate_provider.bar_weight_controller,
        //     keyboardType: TextInputType.number,
        //     inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),],
        //     decoration: const InputDecoration(
        //     hintText: "Enter Bar Weight( )", 
        //   ),
        //   onChanged: (value){
        //       plate_provider.bar_weight_in_kg=num.parse(value);
        //       plate_provider.c_bar=num.parse(value);
        //     },
        //   ),
          
        //   Text(plate_provider.unit_of_plate,style: TextStyle(fontSize: 20),),
        //     for (int i = 0; i <plate_provider.num_inputs; i++)
        //       Row(
        //         children: [
        //           Expanded(
        //             child: TextField(
        //               controller: plate_provider.plate_weights[i],
        //               decoration: const InputDecoration(
        //               hintText: 'Enter Plate weight',
        //             ),
        //             keyboardType: TextInputType.number,
        //             inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),],
        //             onChanged: (value){
        //               int val = int.parse(value);
        //               plate_provider.weights[i]=(num.parse(value));
        //               // while(val>0){
        //               //   print("val is $val");
        //               //   plate_provider.weights.remove(val/10);
        //               //   val~/=10;
        //               // }
        //             },
        //             ),
        //             ),
        //             IconButton(
        //             icon: Icon(Icons.delete),
        //             onPressed: () {
        //               plate_provider.remove();
        //             },
        //           ),
        //         ],
        //       ),
        //       ElevatedButton(
        //           onPressed:(){
        //             plate_provider.addrow();
        //           },
        //             child: Text('Add Weight'),
        //         ),
        //         TextButton(
        //           onPressed: (){
        //             if(plate_provider.weights.length>=1){
        //               plate_provider.flag=true;
        //             plate_provider.calc();}
        //             print("object");
        //             print(plate_provider.weights.length);
        //             Navigator.pop(context);
        //           },
        //           child: Text('Done'),
        //         ),
        //         ElevatedButton(
        //           onPressed: (){
        //             plate_provider.reset();
        //           }, 
        //           child: Text("Reset",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold))
        //         ),            
        //       ],
        //     ),
        // ),