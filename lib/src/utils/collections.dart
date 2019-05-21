import 'dart:core';

/// Util for collections.
class Collections {
  /// Wrap List.reduce with a check list is null or empty.
  static E reduce<E>(List<E> list, E combine(E e0, E e1)) =>
      (list == null || list.isEmpty) ? null : list.reduce(combine);

  /// Wrap List.fold with a check list is null or empty.
  static T fold<T, E>(T init, List<E> list, T combine(T e0, E e1)) =>
      (list == null || list.isEmpty) ? init : list.fold(init, combine);

  /// Flatten list
  /// For example:
  /// List<String> a = ['a', 'b', 'c'];
  /// List<String> b = ['1', '2', '3'];
  /// List<List<String>> list = [a, b] // [[a, b, c], [1, 2, 3]]
  /// List<String> listFlatten = Collections.flatten(list) // [a, b, c, 1, 2, 3]
  static List<E> flatten<E>(List<List<E>> lists) => reduce(lists, merge);

  /// Merge two Iterable
  /// List<String> a = ['a', 'b', 'c'];
  /// List<String> b = ['1', '2', '3'];
  /// List<String> listMerge = Collections.merge(a, b) // [a, b, c, 1, 2, 3]
  static List<T> merge<T>(Iterable<T> a, Iterable<T> b) =>
      <T>[]..addAll(a ?? <T>[])..addAll(b ?? <T>[]);

  static List<T> clone<T>(Iterable<T> a) =>
      (a == null || a.isEmpty) ? <T>[] : (<T>[]..addAll(a));

  /// Cast map to list
  /// Map<String, String> map = {'key0': 'a', 'key1': 'b', 'key2': 'c'};
  /// Function mapFunction = (String value, String key) => value;
  /// List<String> list = Collections.castMapToList<String, String, String>(
  ///        map, mapFunction); // [a, b, c]
  static List<T> castMapToList<T, K, V>(Map<K, V> map0, T map(V v, K k)) =>
      map0.entries
          .map((MapEntry<K, V> entry) => map(entry.value, entry.key))
          .toList();

  /// Cast map with a map function
  static Map<K, V1> castMap<K, V0, V1>(Map<K, V0> map0, V1 map(V0 v0, K k)) =>
      <K, V1>{}..addEntries(castMapToList<MapEntry<K, V1>, K, V0>(
          map0, (V0 v, K k) => MapEntry<K, V1>(k, map(v, k))));

  /// Emit item null and return new list.
  /// List<String> list = ['1', '2', null, '3', null];
  /// print(list)                       // [1, 2, null, 3, null]
  /// print(Collections.compact(list)); // [1, 2, 3]
  static List<T> compact<T>(Iterable<T> list, {bool growable = true}) =>
      list?.where((T e) => e != null)?.toList(growable: growable);

  /// Check if an Object is Empty.
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
