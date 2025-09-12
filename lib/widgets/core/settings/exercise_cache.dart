import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/exercises.dart';

class SettingsExerciseCache extends StatefulWidget {
  const SettingsExerciseCache({super.key});

  @override
  State<SettingsExerciseCache> createState() => _SettingsExerciseCacheState();
}

class _SettingsExerciseCacheState extends State<SettingsExerciseCache> {
  bool _isRefreshLoading = false;
  String _subtitle = '';

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExercisesProvider>(context, listen: false);
    final i18n = AppLocalizations.of(context);

    return ListTile(
      enabled: !_isRefreshLoading,
      title: Text(i18n.settingsExerciseCacheDescription),
      subtitle: _subtitle.isNotEmpty ? Text(_subtitle) : null,
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          key: const ValueKey('cacheIconExercisesRefresh'),
          icon: _isRefreshLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          onPressed: _isRefreshLoading
              ? null
              : () async {
                  setState(() => _isRefreshLoading = true);

                  // Note: status messages are currently left in English on purpose
                  try {
                    setState(() => _subtitle = 'Clearing cache...');
                    await exerciseProvider.clearAllCachesAndPrefs();

                    if (mounted) {
                      setState(() => _subtitle = 'Loading languages and units...');
                    }
                    await exerciseProvider.fetchAndSetInitialData();

                    if (mounted) {
                      setState(() => _subtitle = 'Loading all exercises from server...');
                    }
                    await exerciseProvider.fetchAndSetAllExercises();

                    if (mounted) {
                      setState(() => _subtitle = '');
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isRefreshLoading = false);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(i18n.success)),
                      );
                    }
                  }
                },
        ),
        IconButton(
          key: const ValueKey('cacheIconExercisesDelete'),
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await exerciseProvider.clearAllCachesAndPrefs();

            if (context.mounted) {
              final snackBar = SnackBar(
                content: Text(i18n.settingsCacheDeletedSnackbar),
              );

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          },
        )
      ]),
    );
  }
}
