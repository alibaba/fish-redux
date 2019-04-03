import '../aop.dart';

int _microSecsSinceEpoch() => DateTime.now().microsecondsSinceEpoch;

/// throttle the stream, means every [millis] span functor call once.
/// it difference with [debounce].
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
