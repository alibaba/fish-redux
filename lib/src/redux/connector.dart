import 'basic.dart';

/// Define a basic connector for immutable state.
///     /// Example:
///     class State {
///       final SubState sub;
///       final String name;
///       const State({this.sub, this.name});
///     }
///
///     class SubState {}
///
///     class Conn<State, SubState> extends ImmutableConn<State, SubState> {
///       SubState get(State state) => state.sub;
///       State set(State state, SubState sub) => State(sub: sub, name: state.name);
///     }
abstract class ImmutableConn<T, P> implements AbstractConnector<T, P> {
  const ImmutableConn();

  T set(T state, P subState);

  @override
  SubReducer<T> subReducer(Reducer<P> reducer) {
    return (T state, Action action, bool isStateCopied) {
      final P props = get(state);
      if (props == null) {
        return state;
      }
      final P newProps = reducer(props, action);
      final bool hasChanged = !identical(newProps, props);
      if (hasChanged) {
        final T result = set(state, newProps);
        assert(result != null, 'Expected to return a non-null value.');
        return result;
      }
      return state;
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

/// Define a basic connector for mutable state.
///     /// Example:
///     class State implments Cloneable<State>{
///       SubState sub;
///       String name;
///       State({this.sub, this.name});
///
///       State clone() => State(sub: sub, name: name);
///     }
///
///     class SubState {}
///
///     class Conn<State, SubState> extends MutableConn<State, SubState> {
///       SubState get(State state) => state.sub;
///       void set(State state, SubState sub) => state.sub = sub;
///     }
abstract class MutableConn<T, P> implements AbstractConnector<T, P> {
  const MutableConn();

  void set(T state, P subState);

  @override
  SubReducer<T> subReducer(Reducer<P> reducer) {
    return (T state, Action action, bool isStateCopied) {
      final P props = get(state);
      if (props == null) {
        return state;
      }
      final P newProps = reducer(props, action);
      final bool hasChanged = newProps != props;
      final T copy = (hasChanged && !isStateCopied) ? _clone<T>(state) : state;
      if (hasChanged) {
        set(copy, newProps);
      }
      return copy;
    };
  }
}
