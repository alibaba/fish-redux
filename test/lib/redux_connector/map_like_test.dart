import 'package:fish_redux/fish_redux.dart';
import 'package:flutter_test/flutter_test.dart';

class _Info extends MapLike {
  String name;
  int age = 0;

  _Info(this.name);
}

void main() {
  group('map_like_test', () {
    test('map_like_with_key', () {
      final _Info info = _Info('Tom');

      final AutoInitConnector<_Info, String> nameConnector =
          AutoInitConnector<_Info, String>((_Info info) => info.name,
              key: 'name');

      expect(nameConnector.get(info), equals('Tom'));

      nameConnector.set(info, 'John');

      expect(nameConnector.get(info), equals('John'));

      final AutoInitConnector<_Info, int> ageConnector =
          AutoInitConnector<_Info, int>((_Info info) => info.age, key: 'age');

      expect(ageConnector.get(info), equals(0));
    });

    test('map_like_without_key', () {
      final _Info info = _Info('Tom');

      final AutoInitConnector<_Info, int> generatedKeyConnector =
          AutoInitConnector<_Info, int>((_Info info) => info.age);

      expect(generatedKeyConnector.get(info), equals(0));

      generatedKeyConnector.set(info, 1);

      expect(generatedKeyConnector.get(info), equals(1));
    });

    test('map_like_with_hook', () {
      final _Info info = _Info('Tom');

      String newValue = '';

      final AutoInitConnector<_Info, String> nameConnector =
          AutoInitConnector<_Info, String>((_Info info) => info.name,
              key: 'name', set: (_, String value) => newValue = value);

      expect(newValue, equals(''));
      
      nameConnector.set(info, 'John');

      expect(newValue, equals('John'));
    });
  });
}
