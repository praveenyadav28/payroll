import 'package:shared_preferences/shared_preferences.dart';

class Preference {
  static late SharedPreferences preferences;

  static bool getBool(String key) {
    return preferences.getBool(key) ?? false;
  }

  static String getString(String key) {
    return preferences.getString(key) ?? "";
  }

  static int getint(String key) {
    return preferences.getInt(key) ?? 0;
  }

  static Future<bool> setBool(String key, bool value) async {
    return await preferences.setBool(key, value);
  }

  static Future<bool> setString(String key, String value) async {
    return await preferences.setString(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    return await preferences.setInt(key, value);
  }
}

class PrefKeys {
  static const userstatus = "userstatus";
  static const locationId = "locationId";
  static const userType = "userType";
  static const accessType = "accessType";
  static const calculationType = "calculationType";
  static const coludId = "coludId";
}

logoutPrefData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(PrefKeys.userstatus);
  await prefs.remove(PrefKeys.locationId);
  await prefs.remove(PrefKeys.userType);
  await prefs.remove(PrefKeys.accessType);
  await prefs.remove(PrefKeys.calculationType);
  await prefs.remove(PrefKeys.coludId);
}
