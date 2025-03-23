import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

class PreferenceHelper {
  SharedPreferencesAsync _asyncPref = SharedPreferencesAsync();

  PreferenceHelper._instantiate();

  static final PreferenceHelper _instance = PreferenceHelper._instantiate();

  static SharedPreferencesAsync get asyncPref => _instance._asyncPref;

  static PreferenceHelper get instance => _instance;

  Future<void> migrationSupportFunctionForSharedPreferences() async {
    const SharedPreferencesOptions sharedPreferencesOptions =
        SharedPreferencesOptions();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: prefs,
      sharedPreferencesAsyncOptions: sharedPreferencesOptions,
      migrationCompletedKey: 'migrationCompleted',
    );
    _asyncPref = SharedPreferencesAsync();
  }
}
