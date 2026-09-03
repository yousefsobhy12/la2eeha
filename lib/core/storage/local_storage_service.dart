import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  Future<Set<String>> getStringSet(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key);
    return list?.toSet() ?? <String>{};
  }

  Future<void> setStringSet(String key, Set<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value.toList());
  }
}
