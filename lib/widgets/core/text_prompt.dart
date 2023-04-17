import 'package:flutter/material.dart';

class TextPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ready to start?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Press the action button to begin'),
          ),
        ],
      ),
    );
  }
}
