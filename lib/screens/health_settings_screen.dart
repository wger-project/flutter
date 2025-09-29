import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/health_sync_provider.dart';
import '../../providers/measurement.dart';
import '../../screens/health_service.dart';

class HealthSettingsScreen extends StatefulWidget {
  static const routeName = '/health-settings';

  const HealthSettingsScreen({Key? key}) : super(key: key);

  @override
  State<HealthSettingsScreen> createState() => _HealthSettingsScreenState();
}

class _HealthSettingsScreenState extends State<HealthSettingsScreen> {
  late HealthService healthService;

  @override
  void initState() {
    super.initState();
    // HealthService will be initialized in build with provider
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HealthSyncProvider(),
      child: Consumer<HealthSyncProvider>(
        builder: (context, provider, _) {
          final measurementProvider = Provider.of<MeasurementProvider>(context, listen: false);
          healthService = HealthService(provider, measurementProvider);
          return Scaffold(
            appBar: AppBar(title: const Text('Health Connect')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  const Icon(Icons.sync, size: 50),
                  Text(
                    'Sync your health data with wger',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Text(
                    'You can sync data from Android Health or Apple Health to wger, the '
                    'data will be imported as measurements. You can choose which data to '
                    'sync in the next step.',
                  ),
                  const Text('To stop syncing, disconnect in the settings.'),
                  ElevatedButton(
                    onPressed: provider.isLoading || provider.isConnected
                        ? null
                        : () async {
                            await healthService.requestPermissions();
                          },
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(provider.isConnected ? 'Connected' : 'Connect to Health Data'),
                  ),
                  if (provider.isConnected)
                    ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              await healthService.syncHistoricalData();
                            },
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text('Fetch data'),
                    ),
                  if (provider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
