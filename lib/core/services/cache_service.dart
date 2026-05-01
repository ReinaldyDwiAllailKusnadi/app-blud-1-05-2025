import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String _boxName = 'api_cache';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Future<void> save(String key, dynamic data) async {
    final box = Hive.box(_boxName);
    await box.put(key, data);
  }

  static dynamic get(String key) {
    final box = Hive.box(_boxName);
    return box.get(key);
  }

  static Future<void> clear() async {
    final box = Hive.box(_boxName);
    await box.clear();
  }
}
