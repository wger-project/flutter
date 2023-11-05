// Fl line chart [SAmple 2 ] for testing
// // #TODO  : I may move this content to the core widget file
//

//import 'package:fl_chart_app/presentation/resources/app_resources.dart';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wger/helpers/consts.dart';
import 'package:wger/models/measurements/measurement_entry.dart';
import 'package:wger/widgets/measurements/charts.dart';
//import 'package:intl/intl.dart';
//import 'package:wger/widgets/core/charts.dart';

import 'package:wger/helpers/consts.dart';

import 'package:intl/intl.dart';

class MeasurementChartEntryflchat {
  num value; // this needs to
  DateTime date;

  MeasurementChartEntryflchat(this.value, this.date);
}

class LineChartSample2 extends StatefulWidget {
  //#TODO : Substitute below entries to the old entries for data return comapraison !!
  final List<MeasurementChartEntryflchat> allentries;
  final String unit;

  // entries recieved from original measurement entry (old)
  //final List<MeasurementChartEntry> _entries;

  const LineChartSample2(this.allentries, {this.unit = 'kg'});

  //const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // #TODO : Automatic dates on (x axis)

  SideTitles _bottomTitles() {
    return SideTitles(
      showTitles: true,
      interval: 1,
      getTitlesWidget: (value, meta) {
        // // #TODO : format dates same as old chart
        final getdates =
            value.toInt() < widget.allentries.length ? widget.allentries[value.toInt()].date : "";

        // final datesToStr = getdates.toString();

        // final tempDate = DateTime.parse(getdates.toString());
        // //debugPrint(('tempDates \n'  ) + tempDate.toString() );

        // final finaldates = DateFormat('MM-dd').format(tempDate);
        // debugPrint(('FinaleDates \n') + finaldates);
        //final datestoformat = DateFormatLists.format(tempDate);

        // // # used built in above fun to return date format as (yyyy-mm-dd)
        // debugPrint(datestoformat);

        // #BUG : if dates are formated -- the chart causes error (invalid dates format)
        return SideTitleWidget(axisSide: meta.axisSide, child: Text(getdates.toString()));
      },
    );
  }

  // Widget bottomTitleWidgets(double value, TitleMeta meta) {
  //   const style = TextStyle(
  //     fontWeight: FontWeight.bold,
  //     fontSize: 16,
  //   );

  //   List<String> datesgeneric = [
  //     'Sun',
  //     'Feb',
  //     'Oct',
  //     'Nov',
  //   ];

  //   //MeasurementChartEntry entry ;
  //   // Widget text;
  //   // switch (value.toInt()) {
  //   //   case 2:
  //   //     text = const Text('MAR', style: style);
  //   //     break;
  //   //   case 5:
  //   //     text = const Text('JUN', style: style);
  //   //     break;
  //   //   case 8:
  //   //     text = const Text('SEP', style: style);
  //   //     break;
  //   //   default:
  //   //     text = const Text('', style: style);
  //   //     break;
  //   // }

  //   return SideTitleWidget(
  //     axisSide: meta.axisSide,
  //     child:Text('$datesgeneric'),
  //   );
  // }

  // #TODO : needs to be changed (values for (y) axis)
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );

    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: _bottomTitles(),
        ),

        // #FIXME : Custom bottom titles for dates entry
        // bottomTitles: AxisTitles(
        // sideTitles: SideTitles(
        // showTitles: true,
        // reservedSize: 30,
        // interval: 1,
        // getTitlesWidget: bottomTitleWidgets,
        // ),
        // ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          // spots: const [
          //   FlSpot(0, 3),
          //   FlSpot(2.6, 2),
          //   FlSpot(4.9, 5),
          //   FlSpot(6.8, 3.1),
          //   FlSpot(8, 4),
          //   FlSpot(9.5, 3),
          //   FlSpot(11, 4),
          // ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: _bottomTitles(),
          // sideTitles: SideTitles(
          //   showTitles: true,
          //   reservedSize: 30,
          //   getTitlesWidget: _,
          //   interval: 1,
          // ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          // spots: const [
          //   FlSpot(0, 3.44),
          //   FlSpot(2.6, 3.44),
          //   FlSpot(4.9, 3.44),
          //   FlSpot(6.8, 3.44),
          //   FlSpot(8, 3.44),
          //   FlSpot(9.5, 3.44),
          //   FlSpot(11, 3.44),
          // ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
