import '../aop.dart';

int _microSecsSinceEpoch() => DateTime.now().microsecondsSinceEpoch;

ApplyLikeEnhancer throttle(int millis) {
  return (dynamic Function(List<dynamic>) functor) {
    int last = 0;
    return (List<dynamic> positionalArguments,
        [Map<Symbol, dynamic> namedArguments]) {
      final int now = _microSecsSinceEpoch();
      final int elapsed = now - last;
      if (elapsed >= millis) {
        last = now;
        return functor(positionalArguments);
      }
    };
  };
}
