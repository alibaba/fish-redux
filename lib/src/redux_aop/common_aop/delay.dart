import 'dart:async';

import '../aop.dart';

/// functor will be call after [millis].
ApplyLikeEnhancer delay(int millis) {
  return (dynamic Function(List<dynamic>) functor) {
    return (List<dynamic> positionalArguments,
        [Map<Symbol, dynamic> namedArguments]) async {
      await Future<void>.delayed(Duration(milliseconds: millis));
      return functor(positionalArguments);
    };
  };
}
