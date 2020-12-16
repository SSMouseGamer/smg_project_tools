import 'package:shared_preferences/shared_preferences.dart';
Future<SharedPreferences> getSpInstance() async {
  return await SharedPreferences.getInstance();
}

Future setSpString(String key, String value) async {
  SharedPreferences sp = await getSpInstance();
  sp.setString(key, value);
}

Future<String> getSpString(String key) async {
  SharedPreferences sp = await getSpInstance();
  return sp.getString(key);
}

Future setSpBool(String key, bool value) async {
  SharedPreferences sp = await getSpInstance();
  sp.setBool(key, value);
}

Future<bool> getSpBool(String key) async {
  SharedPreferences sp = await getSpInstance();
  return sp.getBool(key) ?? false;
}

Future setSpInt(String key, int value) async {
  SharedPreferences sp = await getSpInstance();
  sp.setInt(key, value);
}

Future<int> getSpInt(String key) async {
  SharedPreferences sp = await getSpInstance();
  return sp.getInt(key) ?? 0;
}

Future<bool> removeSpEntry(String key) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.remove(key);
}