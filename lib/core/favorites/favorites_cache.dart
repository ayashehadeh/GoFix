import 'package:flutter/foundation.dart';

class FavoritesCache {
  FavoritesCache._();
  static final FavoritesCache instance = FavoritesCache._();

  final ValueNotifier<Set<String>> notifier = ValueNotifier(const {});

  bool isFavorite(String id) => notifier.value.contains(id);

  void setAll(Iterable<String> ids) {
    notifier.value = Set.unmodifiable(ids);
  }

  void set(String id, bool isFavorite) {
    final next = Set<String>.from(notifier.value);
    if (isFavorite) {
      next.add(id);
    } else {
      next.remove(id);
    }
    notifier.value = Set.unmodifiable(next);
  }

  void toggle(String id) {
    final next = Set<String>.from(notifier.value);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    notifier.value = Set.unmodifiable(next);
  }
}
