import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:wger/providers/plate_weights.dart';
import 'package:wger/providers/user.dart';

class AddPlateWeights extends ConsumerStatefulWidget {
  const AddPlateWeights({super.key});

  @override
  ConsumerState<AddPlateWeights> createState() => _AddPlateWeightsState();
}

class _AddPlateWeightsState extends ConsumerState<AddPlateWeights>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(plateWeightsProvider.notifier);
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plateWeightsState = ref.watch(plateWeightsProvider);
    final plateWeightsNotifier = ref.read(plateWeightsProvider.notifier);
    final userProviderInstance = provider.Provider.of<UserProvider>(context);
    final userProfile = userProviderInstance.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Available Plates')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Preferred Unit'),
              DropdownButton<String>(
                value: (userProfile?.isMetric ?? true) ? 'kg' : 'lbs',
                onChanged: (String? newValue) {
                  if (newValue == null) return;
                  final selectedUnitIsMetric = (newValue == 'kg');
                  if (selectedUnitIsMetric != (userProfile?.isMetric ?? true)) {
                    plateWeightsNotifier.unitChange();
                    provider.Provider.of<UserProvider>(context, listen: false).unitChange();
                    _controller.reset();
                    _controller.forward();
                  }
                },
                items: ['kg', 'lbs'].map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: (userProfile == null || userProfile.isMetric)
                ? plateWeightsState.kgWeights.map((number) {
                    return SlideTransition(
                      position: _animation,
                      child: GestureDetector(
                        onTap: () => plateWeightsNotifier.toggleSelection(number),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: plateWeightsState.selectedPlates.contains(number)
                                  ? plateWeightsState.getColor(number)
                                  : const Color.fromARGB(255, 97, 105, 101),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Text(
                              number.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList()
                : plateWeightsState.lbsWeights.map((number) {
                    return SlideTransition(
                      position: _animation,
                      child: GestureDetector(
                        onTap: () => plateWeightsNotifier.toggleSelection(number),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: plateWeightsState.selectedPlates.contains(number)
                                  ? const Color.fromARGB(255, 82, 226, 236)
                                  : const Color.fromARGB(255, 97, 105, 101),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$number lbs',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
              ElevatedButton(
                onPressed: () {
                  plateWeightsNotifier.selectAllPlates();
                },
                child: const Text('Select all'),
              ),
              ElevatedButton(
                onPressed: () {
                  plateWeightsNotifier.resetPlates();
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
