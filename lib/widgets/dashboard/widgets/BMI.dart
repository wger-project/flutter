/*
 * BMI-Dashboard-Widget für wger
 */

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
// Falls du Übersetzungen nutzen willst, sonst entfernen:
// import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/body_weight.dart';
import 'package:wger/providers/user.dart';
import 'package:wger/widgets/dashboard/widgets/nothing_found.dart';
import 'package:wger/widgets/measurements/charts.dart';
import 'package:wger/widgets/measurements/helpers.dart';

// Hilfsfunktion für BMI-Farbe & Kategorie
(Color, String) getBmiInfo(double bmi) {
  if (bmi < 18.5) {
    return (Colors.lightBlueAccent, "Untergewicht");
  } else if (bmi < 25.0) {
    return (Colors.greenAccent, "Normalgewicht");
  } else if (bmi < 30.0) {
    return (Colors.orangeAccent, "Übergewicht");
  } else if (bmi < 35.0) {
    return (Colors.deepOrangeAccent, "Adipositas Grad I");
  } else if (bmi < 40.0) {
    return (Colors.redAccent, "Adipositas Grad II");
  } else {
    return (Colors.red, "Adipositas Grad III");
  }
}

class DashboardBmiWidget extends StatelessWidget {
  const DashboardBmiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final weightProvider = context.watch<BodyWeightProvider>();

    // Wenn keine Größe oder keine Gewichtsdaten vorhanden sind, früh raus
    if (profile?.height == null ||
        profile!.height == 0 ||
        weightProvider.items.isEmpty) {
      return Card(
        // FIX 1: SizedBox.shrink() statt null übergeben
        child: NothingFound(
          "BMI kann nicht berechnet werden",
          "Größe im Profil und Gewichtseinträge nötig",
          const SizedBox.shrink(),
        ),
      );
    }

    // Größe in Meter
    double heightM = profile.height!;
    if (heightM > 3.0) {
      heightM /= 100.0;
    }

    // Historische BMI-Werte aus Gewichts-Einträgen berechnen
    final bmiEntries = weightProvider.items.map((entry) {
      final w = entry.weight.toDouble();
      final bmi = w / (heightM * heightM);
      return MeasurementChartEntry(bmi, entry.date);
    }).toList();

    final (entriesAll, entries7dAvg) = sensibleRange(bmiEntries);

    // Aktueller BMI (basierend auf letztem Eintrag)
    // FIX 2: explizit .toDouble() aufrufen
    final latestBmi = bmiEntries.isNotEmpty
        ? bmiEntries.last.value.toDouble()
        : 0.0;

    final (bmiColor, bmiCategory) = getBmiInfo(latestBmi);

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              "BMI-Verlauf",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            leading: FaIcon(
              FontAwesomeIcons.chartLine,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),

          // Graph
          SizedBox(
            height: 200,
            child: MeasurementChartWidgetFl(
              entriesAll,
              "BMI",
              avgs: entries7dAvg,
            ),
          ),

          // Mittige aktuelle BMI-Anzeige
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Aktueller BMI",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  latestBmi.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: bmiColor,
                  ),
                ),
                Text(
                  bmiCategory,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: bmiColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
