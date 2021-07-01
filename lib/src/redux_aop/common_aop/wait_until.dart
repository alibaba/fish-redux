import 'dart:async';
import '../aop.dart';

/// Wait the future return.
ApplyLikeEnhancer waitUntil() {
  return (dynamic Function(List<dynamic>) functor) {
    bool isLocked = false;
    return (List<dynamic> positionalArguments,
        [Map<Symbol, dynamic>? namedArguments]) {
      if (isLocked) {
        return null;
      } else {
        final Object? result = functor(positionalArguments);
        if (result is Future) {
          isLocked = true;
          return result.whenComplete(() {
            isLocked = false;
          });
        }
        return result;
      }
    };
  };
}
