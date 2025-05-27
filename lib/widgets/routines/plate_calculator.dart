import 'package:flutter/material.dart';

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
    );
  }
}
