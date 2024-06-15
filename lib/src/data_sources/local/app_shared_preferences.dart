import 'package:icorrect/src/data_sources/local/app_shared_preferences_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPref {

  AppSharedPref._();
  static final AppSharedPref _appSharedPref = AppSharedPref._();
  factory AppSharedPref.instance() => _appSharedPref;

  void putBoolean({
    required AppSharedKeys key,
    required bool value,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key.name, value);
  }

  Future<bool?> getBoolean({required AppSharedKeys key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key.name);
  }

  void putString({
    required AppSharedKeys key,
    required String? value,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key.name, value ?? "");
  }

  Future<String> getString({required AppSharedKeys key}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key.name) ?? "";
  }

  Future<bool>? clearShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  Future<String> getCurrentLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppSharedKeys.language.name) ?? "en";
  }
}
