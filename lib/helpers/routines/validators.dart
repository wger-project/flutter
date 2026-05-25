import 'package:wger/l10n/generated/app_localizations.dart';

/// Cross-field validation for a workout log entry, mirroring the
/// reachable part of the backend `WorkoutLog.clean()` rule: at least
/// one of [repetitions] or [weight] must be set.
String? validateWorkoutLogCrossField({
  required num? repetitions,
  required num? weight,
  required AppLocalizations i18n,
}) {
  if (repetitions == null && weight == null) {
    return i18n.weightOrRepsRequired;
  }
  return null;
}
