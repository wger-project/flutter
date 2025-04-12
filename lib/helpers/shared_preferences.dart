import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

/// A helper class that manages preferences using SharedPreferencesAsync
/// and handles migration from the legacy SharedPreferences to
/// SharedPreferencesAsync.
class PreferenceHelper {
  SharedPreferencesAsync _asyncPref = SharedPreferencesAsync();

  PreferenceHelper._instantiate();

  static final PreferenceHelper _instance = PreferenceHelper._instantiate();

  static SharedPreferencesAsync get asyncPref => _instance._asyncPref;

  static PreferenceHelper get instance => _instance;

  /// Migration function that ensures any legacy data stored in
  /// SharedPreferences is migrated to SharedPreferencesAsync. This migration
  /// only happens once, as checked by the migrationCompletedKey.
  ///
  /// [migrationCompletedKey] is used to track if the migration has been
  /// completed.
  Future<void> migrationSupportFunctionForSharedPreferences() async {
    const SharedPreferencesOptions sharedPreferencesOptions = SharedPreferencesOptions();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: prefs,
      sharedPreferencesAsyncOptions: sharedPreferencesOptions,
      migrationCompletedKey: 'migrationCompleted',
    );
    _asyncPref = SharedPreferencesAsync();
  }
}
