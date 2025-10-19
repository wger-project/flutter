import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/nutrition.dart';

class SettingsIngredientCache extends StatelessWidget {
  const SettingsIngredientCache({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    final nutritionProvider = Provider.of<NutritionPlansProvider>(context, listen: false);

    return ListTile(
      title: Text(i18n.settingsIngredientCacheDescription),
      subtitle: Text('${nutritionProvider.ingredients.length} cached ingredients'),
      trailing: IconButton(
        key: const ValueKey('cacheIconIngredients'),
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await nutritionProvider.clearIngredientCache();

          if (context.mounted) {
            final snackBar = SnackBar(content: Text(i18n.settingsCacheDeletedSnackbar));

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
      ),
    );
  }
}
