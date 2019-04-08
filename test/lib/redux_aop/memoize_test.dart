import 'package:fish_redux/fish_redux.dart';
import 'package:flutter_test/flutter_test.dart';

class _Pair {
  int value;
  String label;
  List<Object> children;

  _Pair(this.value, this.label);
}

_Pair mkPair(int value, String label) => _Pair(value, label);

void main() {
  group('memoize_test', () {
    test('memoize_withTwo_test', () {
      final _Pair Function(int, String) memoize2 =
          AOP(<ApplyLikeEnhancer>[memoize()]).withTwo(mkPair);

      final _Pair p0 = memoize2(8, 'hello');
      expect(p0.value == 8, isTrue);
      expect(p0.label == 'hello', isTrue);

      final _Pair p1 = memoize2(8, 'hello');
      expect(p0 == p1, isTrue);

      final _Pair p2 = memoize2(9, 'hello');
      expect(p2.value == 9, isTrue);
      expect(p2.label == 'hello', isTrue);

      expect(p0 == p2, isFalse);
    });
  });
}
