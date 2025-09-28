import 'package:flutter/material.dart';
import 'package:wger/screens/health_service.dart';

class HealthSettingsScreen extends StatefulWidget {
  static const routeName = '/health-settings';

  const HealthSettingsScreen({Key? key}) : super(key: key);

  @override
  State<HealthSettingsScreen> createState() => _HealthSettingsScreenState();
}

class _HealthSettingsScreenState extends State<HealthSettingsScreen> {
  final healthService = HealthService();

  /// Shows a SnackBar with the given message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Data Connection')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text('describe what is happening here'),
            Center(
              child: ElevatedButton(
                child: const Text('Connect to Health Data'),
                onPressed: () async {
                  final granted = await healthService.requestPermissions();
                  // Print result to debug console
                  print('Permissions granted: $granted');
                  if (!granted) {
                    // Show user-facing message if Health Connect is not available
                    _showMessage(
                      'Health Connect is not available on this device. Please install it from the Play Store.',
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
