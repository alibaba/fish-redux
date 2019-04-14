import 'package:fish_redux/fish_redux.dart';
import 'package:flutter_test/flutter_test.dart';

class _Parent {
  int value;
  String label;
  List<Object> children;

  _Parent(this.value, this.label, this.children);
}

class _Info {
  int value;
  String label;

  _Info(this.value, this.label);
}

class _InfoConn extends Reselect2<_Parent, _Info, int, String> {
  @override
  _Info computed(int sub0, String sub1) => _Info(sub0, sub1);

  @override
  int getSub0(_Parent state) => state.value;

  @override
  String getSub1(_Parent state) => state.label;

  @override
  void set(_Parent state, _Info subState) {
    state.value = subState.value;
    state.label = subState.label;
  }
}

void main() {
  group('reselect_test', () {
    final _Parent parent = _Parent(1, 'tag', null);
    final AbstractConnector<_Parent, _Info> r2 = _InfoConn();

    _Info i0, i1, i2, i3;
    i0 = r2.get(parent);

    test('reselect_init', () {
      expect(i0.value == parent.value, isTrue);
      expect(i0.label == parent.label, isTrue);
    });

    test('reselect_nochange', () {
      parent.children = <Object>[];
      i1 = r2.get(parent);
      expect(i0 == i1, isTrue);
    });

    test('reselect_change', () {
      parent.value = 2;
      i2 = r2.get(parent);
      expect(i0 == i2, isFalse);

      i3 = r2.get(parent);
      expect(i2 == i3, isTrue);
    });

    test('reselect_nochange2', () {
      parent.children = <Object>[];
      i3 = r2.get(parent);
      expect(i2 == i3, isTrue);
    });
  });
}
