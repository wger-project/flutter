import 'package:flutter/material.dart';

class BoxedProgressIndicator extends StatelessWidget {
  const BoxedProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
