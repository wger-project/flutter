import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestDashboard extends StatelessWidget {
  final bool showWidget;

  const TestDashboard({super.key, required this.showWidget});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const Text('Routine Widget'), // Other stuff
            
            if (showWidget)
              const Text('Nutritional plan'), 
              
            const Text('Weight Widget'), // Other stuff
          ],
        ),
      ),
    );
  }
}

void main() {
  // Test 1: Simulate "No Plan" -> Logic should HIDE it
  testWidgets('Dashboard HIDES nutrition widget when no plan is active', (WidgetTester tester) async {
    // Build our skeleton dashboard with showWidget = false
    await tester.pumpWidget(const TestDashboard(showWidget: false));

    // Assert: The text "Nutritional plan" should NOT be there
    expect(find.text('Nutritional plan'), findsNothing);
  });

  // Test 2: Simulate "Active Plan" -> Logic should SHOW it
  testWidgets('Dashboard SHOWS nutrition widget when plan IS active', (WidgetTester tester) async {
    // Build our skeleton dashboard with showWidget = true
    await tester.pumpWidget(const TestDashboard(showWidget: true));

    // Assert: The text "Nutritional plan" SHOULD be there
    expect(find.text('Nutritional plan'), findsOneWidget);
  });
}
