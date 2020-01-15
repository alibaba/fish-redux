import 'package:fish_redux/fish_redux.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('collections_test', () {
    test('collections_reduce', () {
      expect(Collections.reduce(null, (int v, int p) => p + v), isNull);
      expect(
          Collections.reduce(<int>[1, 2, 3, 4], (int v, int p) => p + v) == 10,
          isTrue);
    });

    test('collections_flatten', () {
      final List<String> a = <String>['a', 'b'];
      final List<String> b = <String>['1', '2'];
      final List<List<String>> list = <List<String>>[a, b];
      final List<String> listFlatten = Collections.flatten(list);

      expect(listFlatten, orderedEquals(<String>['a', 'b', '1', '2']));
    });

    test('collections_merge', () {
      final List<String> a = <String>['1', '2'];
      final List<String> b = <String>['3', '4'];
      final List<String> merge = Collections.merge(a, b);

      expect(merge, orderedEquals(<String>['1', '2', '3', '4']));
    });

    test('collections_clone', () {
      final List<String> list = <String>['hello', 'world'];

      expect(
          Collections.clone(list), orderedEquals(<String>['hello', 'world']));
    });

    test('collections_castMapToList', () {
      final Map<String, String> map = <String, String>{
        'name': 'John',
        'gender': 'male',
        'age': '25'
      };
      final List<String> list =
          Collections.castMapToList(map, (String value, String key) => value);
      expect(Collections.clone(list),
          orderedEquals(<String>['John', 'male', '25']));
    });

    test('collections_isEmpty', () {
      expect(Collections.isEmpty(null), isTrue);

      expect(Collections.isEmpty(<String>[]), isTrue);
      expect(Collections.isEmpty(<String>['v']), isFalse);
      expect(Collections.isNotEmpty(<String>['v']), isTrue);

      expect(Collections.isEmpty(''), isTrue);

      expect(Collections.isEmpty(<String, String>{'name': 'Tom'}), isFalse);
    });
  });
}
