import 'package:fish_redux/fish_redux.dart';
import 'package:test/test.dart';

void main() {
  group('auto_dispose', () {
    test('create', () {
      final AutoDispose autoDispose = AutoDispose();
      expect(autoDispose, isNotNull);
      expect(autoDispose.isDisposed, isFalse);
    });

    test('dispose', () {
      final AutoDispose autoDispose = AutoDispose();
      expect(autoDispose, isNotNull);
      expect(autoDispose.isDisposed, isFalse);
      autoDispose.dispose();
      expect(autoDispose.isDisposed, isTrue);
    });

    test('follow', () {
      final AutoDispose parent = AutoDispose();
      expect(parent.isDisposed, isFalse);

      final AutoDispose follow0 = AutoDispose();
      follow0.setParent(parent);
      expect(follow0.isDisposed, isFalse);
      follow0.dispose();
      expect(follow0.isDisposed, isTrue);
      expect(parent.isDisposed, isFalse);

      final AutoDispose follow1 = AutoDispose();
      follow1.setParent(parent);
      expect(follow1.isDisposed, isFalse);

      parent.dispose();
      expect(parent.isDisposed, isTrue);
      expect(follow1.isDisposed, isTrue);

      final AutoDispose follow2 = AutoDispose();
      follow2.setParent(parent);
      expect(follow2.isDisposed, isTrue);
    });

    test('refollow', () {
      final AutoDispose parent0 = AutoDispose();
      final AutoDispose parent1 = AutoDispose();
      expect(parent0.isDisposed, isFalse);
      expect(parent1.isDisposed, isFalse);

      final AutoDispose follow0 = AutoDispose();
      follow0.setParent(parent0);
      expect(follow0.isDisposed, isFalse);

      follow0.setParent(parent1);
      expect(follow0.isDisposed, isFalse);

      parent0.dispose();
      expect(parent0.isDisposed, isTrue);
      expect(follow0.isDisposed, isFalse);

      parent1.dispose();
      expect(parent1.isDisposed, isTrue);
      expect(follow0.isDisposed, isTrue);
    });

    test('follower', () {
      final AutoDispose parent = AutoDispose();
      expect(parent.isDisposed, isFalse);

      final AutoDispose follow0 = parent.registerOnDisposed(null);
      expect(follow0.isDisposed, isFalse);
      follow0.dispose();
      expect(follow0.isDisposed, isTrue);
      expect(parent.isDisposed, isFalse);

      final AutoDispose follow1 = parent.registerOnDisposed(null);
      expect(follow1.isDisposed, isFalse);

      parent.dispose();
      expect(parent.isDisposed, isTrue);
      expect(follow1.isDisposed, isTrue);

      final AutoDispose follow2 = parent.registerOnDisposed(null);
      expect(follow2.isDisposed, isTrue);
    });

    test('onDisposed', () {
      int pCount = 0;
      final AutoDispose parent = AutoDispose()
        ..onDisposed(() {
          pCount++;
        });
      expect(parent.isDisposed, isFalse);
      expect(pCount, equals(0));

      int fCount = 0;
      final AutoDispose follow = parent.registerOnDisposed(() {
        fCount++;
      });
      expect(fCount, equals(0));

      follow.dispose();
      expect(fCount, equals(1));
      expect(pCount, equals(0));

      parent.dispose();
      expect(fCount, equals(1));
      expect(pCount, equals(1));

      follow.dispose();
      expect(fCount, equals(1));
      expect(pCount, equals(1));

      parent.dispose();
      expect(fCount, equals(1));
      expect(pCount, equals(1));
    });
  });
}
