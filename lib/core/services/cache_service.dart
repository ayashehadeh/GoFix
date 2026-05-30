class _CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  _CacheEntry(this.data, Duration ttl)
      : expiresAt = DateTime.now().add(ttl);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class CacheService {
  final Map<String, _CacheEntry<dynamic>> _store = {};

  T? get<T>(String key) {
    final entry = _store[key];
    if (entry == null || entry.isExpired) {
      _store.remove(key);
      return null;
    }
    return entry.data as T;
  }

  void set<T>(String key, T data,
      {Duration ttl = const Duration(minutes: 10)}) {
    _store[key] = _CacheEntry<T>(data, ttl);
  }

  void invalidate(String key) => _store.remove(key);

  void invalidateWhere(bool Function(String key) test) =>
      _store.removeWhere((key, _) => test(key));

  void clear() => _store.clear();
}
