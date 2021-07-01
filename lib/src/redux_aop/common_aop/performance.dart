import 'dart:async';

import '../aop.dart';
import 'debug.dart';

int _microSecsSinceEpoch() => DateTime.now().microsecondsSinceEpoch;

/// functor performance by time consuming.
ApplyLikeEnhancer performanceAOP(String tag) {
  return isDebug()
      ? (dynamic Function(List<dynamic>) functor) {
          return (List<dynamic> positionalArguments,
              [Map<Symbol, dynamic>? namedArguments]) {
            final int marked = DateTime.now().microsecondsSinceEpoch;
            final Object result = functor(positionalArguments);
            if (result is Future) {
              result.then<dynamic>((Object r) {
                print(
                    '$tag performance <Future>: ${_microSecsSinceEpoch() - marked}');
                return r;
              } as FutureOr<dynamic> Function(dynamic));
            } else {
              print('$tag performance: ${_microSecsSinceEpoch() - marked}');
            }
            return result;
          };
        }
      : ApplyLikeEnhancerIdentity;
}
