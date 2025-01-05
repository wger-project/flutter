import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:wger/providers/plate_weights.dart';
import 'package:wger/providers/user.dart';

class AddPlateWeights extends StatefulWidget {
  const AddPlateWeights({super.key});

  @override
  State<AddPlateWeights> createState() => _AddPlateWeightsState();
}

class _AddPlateWeightsState extends State<AddPlateWeights> with SingleTickerProviderStateMixin{
late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      Provider.of<PlateWeights>(context,listen: false).readPlates();
    });
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start off-screen
      end: const Offset(0.0, 0.0),   // End at original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool unit = true;
    return Consumer2<PlateWeights,UserProvider> (
      builder:(context,plateProvider,userProvider,child)=> Scaffold (
        appBar: AppBar (
          title: const Text('Select Available Plates'),
        ),
        body: Column (
          children: [
            Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Preferred Unit'),
                DropdownButton (
                  onChanged: (newValue){
                    plateProvider.clear();
                    if(newValue=='kg') {
                      unit = true;
                    } else {
                      unit = false;
                    }
                    print(unit);
                    if(unit != userProvider.profile?.isMetric) {
                      userProvider.unitChange();
                      //plateProvider.unitChange();
                      _controller.reset();
                      _controller.forward();
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
                children: (userProvider.profile?.weightUnitStr == 'kg')
                  ? plateProvider.kgWeights.map((number) {
                      return SlideTransition(
                        position: _animation,
                        child: GestureDetector(
                          onTap: () => plateProvider.toggleSelection(number),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
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
                          ),
                        ),
                      );
                    }).toList()
                  : plateProvider.lbsWeights.map((number) {
                      return SlideTransition(
                        position: _animation,
                        child: GestureDetector(
                          onTap: () => plateProvider.toggleSelection(number),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
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
                    plateProvider.saveIntoSharedPrefs();
                    if(plateProvider.selectedWeights.isNotEmpty){
                        plateProvider.plateChoiceExists=true;
                        plateProvider.calculatePlates();
                      }
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