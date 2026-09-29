class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final Map<String, String> _memoryCache = {};

  Future<void> init() async {
    // Initial local cache hydration
  }

  Future<void> setString(String key, String value) async {
    _memoryCache[key] = value;
  }

  String? getString(String key) {
    return _memoryCache[key];
  }

  Future<void> setBool(String key, bool value) async {
    _memoryCache[key] = value.toString();
  }

  bool getBool(String key, {bool defaultValue = false}) {
    final val = _memoryCache[key];
    if (val == null) return defaultValue;
    return val.toLowerCase() == 'true';
  }

  Future<void> remove(String key) async {
    _memoryCache.remove(key);
  }

  Future<void> clear() async {
    _memoryCache.clear();
  }
}
