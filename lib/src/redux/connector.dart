import '../redux_component/dependent.dart';
import 'basic.dart';
abstract class MutableConn<T, P> {
  const MutableConn();

  void set(T state, P subState);

  P get(T state);

  /// For mutable state, there are three abilities needed to be met.
  ///     1. get: (S) => P
  ///     2. set: (S, P) => void
  ///     3. shallow copy: s.clone()
  ///
  /// For immutable state, there are two abilities needed to be met.
  ///     1. get: (S) => P
  ///     2. set: (S, P) => S
  ///
  /// See in [connector].
  SubReducer<T> subReducer(Reducer<P> reducer) {
    return reducer == null
        ? null
        : (T state, Action action, bool isStateCopied) {
            final P props = get(state);
            if (props == null) {
              return state;
            }
            final P newProps = reducer(props, action);
            final bool hasChanged = newProps != props;
            final T copy =
                (hasChanged && !isStateCopied) ? _clone<T>(state) : state;
            if (hasChanged) {
              set(copy, newProps);
            }
            return copy;
          };
  }
}

/// Definition of Cloneable
abstract class Cloneable<T extends Cloneable<T>> {
  T clone();
}

/// how to clone an object
dynamic _clone<T>(T state) {
  if (state is Cloneable) {
    return state.clone();
  } else if (state is List) {
    return state.toList();
  } else if (state is Map<String, dynamic>) {
    return <String, dynamic>{}..addAll(state);
  } else if (state == null) {
    return null;
  } else {
    throw ArgumentError(
        'Could not clone this state of type ${state.runtimeType}.');
  }
}

class NoneConn<T> extends ConnOp<T, T> {
  const NoneConn();

  @override
  T get(T state) => state;

  @override
  T set(T state, T subState) => subState;
}

class ConnOp<T, P> extends MutableConn<T, P> with ConnOpMixin<T, P> {
  final P Function(T) _getter;
  final void Function(T, P) _setter;

  const ConnOp({
    P Function(T) get,
    void Function(T, P) set,
  })  : _getter = get,
        _setter = set;

  @override
  P get(T state) => _getter(state);

  @override
  void set(T state, P subState) => _setter(state, subState);
}