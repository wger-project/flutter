import 'dart:ui';

const LIST_OF_COLORS8 = [
  Color(0xFF2A4C7D),
  Color(0xFF5B5291),
  Color(0xFF8E5298),
  Color(0xFFBF5092),
  Color(0xFFE7537E),
  Color(0xFFFF6461),
  Color(0xFFFF813D),
  Color(0xFFFFA600),
];

const LIST_OF_COLORS5 = [
  Color(0xFF2A4C7D),
  Color(0xFF825298),
  Color(0xFFD45089),
  Color(0xFFFF6A59),
  Color(0xFFFFA600),
];

const LIST_OF_COLORS3 = [
  Color(0xFF2A4C7D),
  Color(0xFFD45089),
  Color(0xFFFFA600),
];

const COLOR_SURPLUS = Color.fromARGB(255, 231, 71, 71);

Iterable<Color> generateChartColors(int nrOfItems) sync* {
  final List<Color> colors;

  if (nrOfItems <= 3) {
    colors = LIST_OF_COLORS3;
  } else if (nrOfItems <= 5) {
    colors = LIST_OF_COLORS5;
  } else {
    colors = LIST_OF_COLORS8;
  }

  for (final color in colors) {
    yield color;
  }
}
