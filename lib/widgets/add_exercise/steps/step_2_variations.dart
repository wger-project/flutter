import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/add_exercise.dart';
import 'package:wger/providers/exercise_state_notifier.dart';

class Step2Variations extends ConsumerWidget {
  final GlobalKey<FormState> formkey;

  const Step2Variations({required this.formkey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseProvider = ref.read(exerciseStateProvider.notifier);

    return Form(
      key: formkey,
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).whatVariationsExist,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Exercise bases with variations
                  ...exerciseProvider.exerciseByVariation.keys.map(
                    (key) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            //mainAxisSize: MainAxisSize.max,
                            children: [
                              ...exerciseProvider.exerciseByVariation[key]!.map(
                                (base) => Text(
                                  base
                                      .getTranslation(Localizations.localeOf(context).languageCode)
                                      .name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        provider.Consumer<AddExerciseProvider>(
                          builder: (ctx, provider, __) => Switch(
                            value: provider.variationId == key,
                            onChanged: (state) => provider.variationId = key,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Exercise bases without variations
                  ...exerciseProvider.allExercises
                      .where((b) => b.variationId == null)
                      .map(
                        (base) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    base
                                        .getTranslation(
                                          Localizations.localeOf(context).languageCode,
                                        )
                                        .name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                            provider.Consumer<AddExerciseProvider>(
                              builder: (ctx, provider, __) => Switch(
                                value: provider.variationConnectToExercise == base.id,
                                onChanged: (state) => provider.variationConnectToExercise = base.id,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
