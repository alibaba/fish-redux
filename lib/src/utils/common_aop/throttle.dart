import '../aop.dart';

int _microsecsSinceEpoch() => DateTime.now().microsecondsSinceEpoch;

ApplyLikeEnhancer throttle(int millis) {
  return (dynamic Function(List<dynamic>) functor) {
    int last = 0;
    return (List<dynamic> positionalArguments,
        [Map<Symbol, dynamic> namedArguments]) {
      final int now = _microsecsSinceEpoch();
      final int elapsed = now - last;
      if (elapsed >= millis) {
        last = now;
        return functor(positionalArguments);
      }
    };
  };
}
