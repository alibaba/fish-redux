import 'dart:async';

import '../aop.dart';

/// debounce the stream, means the [millis] span functor call once and drop other event.
/// it difference with [throttle].
ApplyLikeEnhancer debounce(int millis) {
  return (dynamic Function(List<dynamic>) functor) {
    int idGenerator = 0;
    return (List<dynamic> positionalArguments,
        [Map<Symbol, dynamic>? namedArguments]) async {
      final int newId = ++idGenerator;
      await Future<void>.delayed(Duration(milliseconds: millis));
      if (newId == idGenerator) {
        return functor(positionalArguments);
      }
    };
  };
}
