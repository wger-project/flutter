import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/plate_weights.dart';

class PlateWeight extends StatelessWidget {
  final num value;
  final Color color;
  final bool isSelected;
  final double size;
  final double padding;
  final double margin;

  const PlateWeight({
    super.key,
    required this.value,
    required this.color,
    this.isSelected = true,
    this.size = 50,
    this.padding = 8,
    this.margin = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ValueKey('plateWeight-$value'),
      height: size,
      width: size,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(margin),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.black12,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: isSelected ? 2 : 0),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ConfigureAvailablePlates extends ConsumerStatefulWidget {
  const ConfigureAvailablePlates({super.key});

  @override
  ConsumerState<ConfigureAvailablePlates> createState() => _AddPlateWeightsState();
}

class _AddPlateWeightsState extends ConsumerState<ConfigureAvailablePlates> {
  final TextEditingController _barWeightController = TextEditingController();
  bool _barWeightInitialized = false;
  String? _barWeightError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(plateCalculatorProvider.notifier);
    });
  }

  @override
  void dispose() {
    _barWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final numberFormat = NumberFormat.decimalPattern(Localizations.localeOf(context).toString());

    final plateWeightsState = ref.watch(plateCalculatorProvider);
    final plateWeightsNotifier = ref.read(plateCalculatorProvider.notifier);
    // final userProvider = provider.Provider.of<UserProvider>(context);

    // Initialise the field with the current value and keep it in sync when the
    // bar weight changes from outside the field (data loaded from prefs, unit
    // switch, preset chips), without clobbering what the user is typing.
    if (!_barWeightInitialized) {
      _barWeightController.text = numberFormat.format(plateWeightsState.barWeight);
      _barWeightInitialized = true;
    }
    ref.listen(plateCalculatorProvider.select((s) => s.barWeight), (_, barWeight) {
      if (numberFormat.tryParse(_barWeightController.text) != barWeight) {
        _barWeightController.text = numberFormat.format(barWeight);
        _barWeightError = null;
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: DropdownMenu<WeightUnitEnum>(
            key: const ValueKey('weightUnitDropdown'),
            width: double.infinity,
            initialSelection: plateWeightsState.isMetric ? WeightUnitEnum.kg : WeightUnitEnum.lb,
            requestFocusOnTap: true,
            label: Text(i18n.unit),
            onSelected: (WeightUnitEnum? unit) {
              if (unit == null) {
                return;
              }
              plateWeightsNotifier.unitChange(unit: unit);
              // userProvider.changeUnit(changeTo: unit.name);
              // userProvider.saveProfile();
            },
            dropdownMenuEntries: WeightUnitEnum.values.map((unit) {
              return DropdownMenuEntry<WeightUnitEnum>(
                value: unit,
                label: unit == WeightUnitEnum.kg ? i18n.kg : i18n.lb,
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                key: const ValueKey('barWeightField'),
                controller: _barWeightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: i18n.barWeight,
                  errorText: _barWeightError,
                ),
                onChanged: (value) {
                  final parsed = numberFormat.tryParse(value);
                  setState(() {
                    if (parsed == null || parsed <= 0) {
                      _barWeightError = i18n.enterValidNumber;
                    } else {
                      _barWeightError = null;
                      plateWeightsNotifier.setBarWeight(parsed);
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: plateWeightsState.availableBarsWeights.map((value) {
                  return ChoiceChip(
                    key: ValueKey('barWeightChip-$value'),
                    label: Text(value.toString()),
                    selected: plateWeightsState.barWeight == value,
                    onSelected: (_) => plateWeightsNotifier.setBarWeight(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        SwitchListTile(
          key: const ValueKey('useColorsSwitch'),
          title: Text(i18n.useColors),
          value: plateWeightsState.useColors,
          onChanged: (state) => plateWeightsNotifier.setUseColors(state),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            const double widthThreshold = 450.0;
            final int crossAxisCount = constraints.maxWidth > widthThreshold ? 10 : 5;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: plateWeightsState.availablePlates.map((number) {
                final bool isSelected = plateWeightsState.selectedPlates.contains(number);
                return GestureDetector(
                  onTap: () => plateWeightsNotifier.toggleSelection(number),
                  child: PlateWeight(
                    value: number,
                    isSelected: isSelected,
                    color: plateWeightsState.getColor(number),
                  ),
                );
              }).toList(),
            );
          },
        ),
        FilledButton(
          onPressed: () {
            plateWeightsNotifier.saveToSharedPrefs();
            Navigator.pop(context);
          },
          child: Text(i18n.save),
        ),
      ],
    );
  }
}
