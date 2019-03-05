import 'dart:core';

class Collections {
  static E reduce<E>(List<E> list, E combine(E e0, E e1)) =>
      (list == null || list.isEmpty) ? null : list.reduce(combine);

  static T fold<T, E>(T init, List<E> list, T combine(T e0, E e1)) =>
      (list == null || list.isEmpty) ? init : list.fold(init, combine);

  static List<E> flatten<E>(List<List<E>> lists) => reduce(lists, merge);

  static List<T> merge<T>(Iterable<T> a, Iterable<T> b) =>
      <T>[]..addAll(a ?? <T>[])..addAll(b ?? <T>[]);

  static List<T> castMapToList<T, K, V>(Map<K, V> map0, T map(V v, K k)) =>
      map0.entries
          .map((MapEntry<K, V> entry) => map(entry.value, entry.key))
          .toList();

  static Map<K, V1> castMap<K, V0, V1>(Map<K, V0> map0, V1 map(V0 v0, K k)) =>
      <K, V1>{}..addEntries(castMapToList<MapEntry<K, V1>, K, V0>(
          map0, (V0 v, K k) => MapEntry<K, V1>(k, map(v, k))));

  static List<T> compact<T>(Iterable<T> list, {bool growable = true}) =>
      list?.where((T e) => e != null)?.toList(growable: growable);

  static bool isEmpty(Object value) {
    if (value == null) {
      return true;
    } else {
      if (value is String) {
        return value.isEmpty;
      } else if (value is List) {
        return value.isEmpty;
      } else if (value is Map) {
        return value.isEmpty;
      } else if (value is Set) {
        return value.isEmpty;
      } else {
        return false;
      }
    }
  }

  static bool isNotEmpty(Object value) => !isEmpty(value);
}
