import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('FITALIVE'), backgroundColor: Colors.red),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LineCharts(),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Nutrition Chart",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic))),
          ],
        ),
      ),
    );
  }
}

class LineCharts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const cutOffYValue = 0.0;
    const yearTextStyle = TextStyle(fontSize: 12, color: Colors.black);

    return SizedBox(
      width: 360,
      height: 250,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(1, 1),
                FlSpot(2, 3),
                FlSpot(3, 4),
                FlSpot(3, 5),
                FlSpot(4, 4)
              ],
              isCurved: true,
              barWidth: 2,
              colors: [
                Colors.green,
              ],
              belowBarData: BarAreaData(
                show: true,
                colors: [Colors.lightBlue.withOpacity(0.5)],
                cutOffY: cutOffYValue,
                applyCutOffY: true,
              ),
              aboveBarData: BarAreaData(
                show: true,
                colors: [Colors.lightGreen.withOpacity(0.5)],
                cutOffY: cutOffYValue,
                applyCutOffY: true,
              ),
              dotData: FlDotData(
                show: false,
              ),
            ),
          ],
          minY: 0,
          titlesData: FlTitlesData(
            bottomTitles: SideTitles(
                showTitles: true,
                reservedSize: 5,
                textStyle: yearTextStyle,
                getTitles: (value) {
                  switch (value.toInt()) {
                    case 0:
                      return '10-16';
                    case 1:
                      return '17-25';
                    case 2:
                      return '26-34';
                    case 3:
                      return '35-42';
                    case 4:
                      return '43-50';

                    default:
                      return '';
                  }
                }),
            leftTitles: SideTitles(
              showTitles: true,
              getTitles: (value) {
                return '\% ${value * 5}';
              },
            ),
          ),
          axisTitleData: FlAxisTitleData(
              leftTitle: AxisTitle(
                showTitle: true,
                titleText: 'Protein Intake',
                margin: 10,
              ),
              bottomTitle: AxisTitle(
                  showTitle: true,
                  margin: 10,
                  titleText: 'AGE Range',
                  textStyle: yearTextStyle,
                  textAlign: TextAlign.center)),
          gridData: FlGridData(
            show: true,
            checkToShowHorizontalLine: (double value) {
              return value == 1 || value == 2 || value == 3 || value == 4;
            },
          ),
        ),
      ),
    );
  }
}
