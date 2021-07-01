import 'dart:async';

import '../aop.dart';
import 'debug.dart';

/// AOP for functor log.
ApplyLikeEnhancer logAOP(String tag) {
  return isDebug()
      ? (dynamic Function(List<dynamic>) functor) {
          return (List<dynamic> positionalArguments,
              [Map<Symbol, dynamic>? namedArguments]) {
            print('$tag input: $positionalArguments');
            final Object result = functor(positionalArguments);
            if (result is Future) {
              result.then<dynamic>((Object r) {
                print('$tag output <Future>: $r');
                return r;
              } as FutureOr<dynamic> Function(dynamic));
            } else {
              print('$tag output: $result');
            }
            return result;
          };
        }
      : ApplyLikeEnhancerIdentity;
}
