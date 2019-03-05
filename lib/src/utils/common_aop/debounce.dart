import 'dart:async';

import '../aop.dart';

ApplyLikeEnhancer debounce(int millis) {
  return (dynamic Function(List<dynamic>) functor) {
    int idGenerator = 0;
    return (List<dynamic> positionalArguments,
        [Map<Symbol, dynamic> namedArguments]) async {
      final int newId = ++idGenerator;
      await Future<void>.delayed(Duration(milliseconds: millis));
      if (newId == idGenerator) {
        return functor(positionalArguments);
      }
    };
  };
}
