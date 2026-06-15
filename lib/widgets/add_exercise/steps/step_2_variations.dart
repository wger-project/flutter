import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wger/l10n/generated/app_localizations.dart';
import 'package:wger/providers/add_exercise_notifier.dart';
import 'package:wger/providers/exercises_notifier.dart';

class Step2Variations extends ConsumerWidget {
  final GlobalKey<FormState> formkey;

  const Step2Variations({required this.formkey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reactive: rebuilds when the exercise catalogue changes. Falls back to
    // an empty state while the stream hasn't emitted yet.
    final exerciseState = ref.watch(exercisesProvider).value ?? const ExerciseState([]);
    final byVariation = exerciseState.getByVariation();

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
                  ...byVariation.keys.map(
                    (key) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            //mainAxisSize: MainAxisSize.max,
                            children: [
                              ...byVariation[key]!.map(
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
                        Consumer(
                          builder: (ctx, ref, __) {
                            final state = ref.watch(addExerciseProvider);
                            return Switch(
                              value: state.variationGroup == key,
                              onChanged: (newState) => ref
                                  .read(addExerciseProvider.notifier)
                                  .setVariationGroup(newState ? key : null),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Exercise bases without variations
                  ...exerciseState.exercises
                      .where((b) => b.variationGroup == null)
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
                            Consumer(
                              builder: (ctx, ref, __) {
                                final state = ref.watch(addExerciseProvider);
                                return Switch(
                                  value: state.variationConnectToExercise == base.id,
                                  onChanged: (_) => ref
                                      .read(addExerciseProvider.notifier)
                                      .setVariationConnectToExercise(base.id),
                                );
                              },
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
