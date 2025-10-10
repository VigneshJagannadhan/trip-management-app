import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveObject(String key, Map<String, dynamic> object);
  Future<Map<String, dynamic>?> getObject(String key);
  Future<void> saveList(String key, List<dynamic> list);
  Future<List<dynamic>?> getList(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

class SharedPreferencesStorageService implements StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs?.getString(key);
  }

  @override
  Future<void> saveObject(String key, Map<String, dynamic> object) async {
    final jsonString = json.encode(object);
    await _prefs?.setString(key, jsonString);
  }

  @override
  Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = _prefs?.getString(key);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<void> saveList(String key, List<dynamic> list) async {
    final jsonString = json.encode(list);
    await _prefs?.setString(key, jsonString);
  }

  @override
  Future<List<dynamic>?> getList(String key) async {
    final jsonString = _prefs?.getString(key);
    if (jsonString != null) {
      return json.decode(jsonString) as List<dynamic>;
    }
    return null;
  }

  @override
  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs?.clear();
  }
}
