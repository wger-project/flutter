import 'package:flutter/material.dart';
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
    return Consumer<PlateWeights> (
      builder:(context,plateProvider,child)=> Scaffold (
        appBar: AppBar (
          title: const Text('Enter Custom Plate Weights'),
        ),
        body: Column (
          children: [
            Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Kg or lbs'),
                DropdownButton (
                  onChanged: (newValue){
                    plateProvider.clear();
                    if((newValue!) != plateProvider.unitOfPlate) {
                      plateProvider.unitChange();
                    }   
                  }, 
                  items: ['kg','lbs'].map((unit){
                    return DropdownMenuItem<String> (
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                ),
              ],  
            ),
            SingleChildScrollView (
              scrollDirection: Axis.horizontal,
              child: Row (
                children: plateProvider.unitOfPlate == 'kg'
                  ? plateProvider.kgWeights.map((number) {
                      return GestureDetector(
                        onTap: () => plateProvider.toggleSelection(number),
                        child: Container (
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration (
                            color: plateProvider.selectedWeights.contains(number)
                                ? const Color.fromARGB(255, 82, 226, 236)
                                : const Color.fromARGB(255, 97, 105, 101),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text (
                            '$number kg', // Add unit to text
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList()
                  : plateProvider.lbsWeights.map((number) {
                      return GestureDetector(
                        onTap: () => plateProvider.toggleSelection(number),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration (
                            color: plateProvider.selectedWeights.contains(number)
                                ? const Color.fromARGB(255, 82, 226, 236)
                                : const Color.fromARGB(255, 97, 105, 101),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text (
                            '$number lbs', // Add unit to text
                            style: const TextStyle(
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
                    if(plateProvider.selectedWeights.isNotEmpty){
                      plateProvider.flag=true;
                      plateProvider.calculatePlates();}
                      Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
                ElevatedButton(
                  onPressed: (){
                    plateProvider.resetPlates();
                  }, 
                  child: const Text('Reset',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold))
                ),
              ],
            ),
          ]
        ),
      ),
    );
  }
}