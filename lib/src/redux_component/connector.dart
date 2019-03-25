import '../redux/basic.dart';
import 'basic.dart';
import 'dependent.dart';
import 'logic.dart';

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

abstract class BaseConn<T, P> implements AbstractConnector<T, P> {
  const BaseConn();

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

class Connector<T, P> extends BaseConn<T, P> {
  final P Function(T) _getter;
  final void Function(T, P) _setter;

  const Connector({
    P Function(T) get,
    void Function(T, P) set,
  })  : _getter = get,
        _setter = set;

  @override
  P get(T state) => _getter(state);

  @override
  void set(T state, P subState) => _setter(state, subState);
}

class ConnOp<S, P> extends BaseConn<S, P> {
  final P Function(S) _getter;
  final void Function(S, P) _setter;

  ConnOp({P Function(S) get, void Function(S, P) set})
      : _getter = get,
        _setter = set;

  @override
  P get(S state) => _getter(state);
  @override
  void set(S state, P subState) => _setter(state, subState);

  Dependent<S> operator +(Logic<P> logic) => createDependent<S, P>(this, logic);
}

abstract class MapLike {
  Map<String, Object> _fieldsMap = <String, Object>{};

  void clear() => _fieldsMap.clear();

  Object operator [](String key) => _fieldsMap[key];

  void operator []=(String key, Object value) => _fieldsMap[key] = value;

  bool containsKey(String key) => _fieldsMap.containsKey(key);

  void copyFrom(MapLike from) =>
      _fieldsMap = <String, Object>{}..addAll(from._fieldsMap);
}

AbstractConnector<T, P> withMapLike<T extends MapLike, P>(String key) =>
    ConnOp<T, P>(
      get: (T state) => state[key],
      set: (T state, P sub) => state[key] = sub,
    );

class IdGenerator {
  int _gID = 0;
  String _prefix = '';
  String next() {
    if (++_gID >= 0x3FFFFFFFFFFFFFFF) {
      _gID = 0;
      _prefix = '\$' + _prefix;
    }
    return _prefix + _gID.toString();
  }
}

class AutoInitConnector<T extends MapLike, P> extends ConnOp<T, P> {
  static final IdGenerator _gen = IdGenerator();

  final String _key;
  final void Function(T state, P sub) _setHook;
  final P Function(T state) init;

  AutoInitConnector(this.init, {String key, void set(T state, P sub)})
      : assert(init != null),
        _setHook = set,
        _key = key ?? _gen.next();

  @override
  P get(T state) =>
      state.containsKey(_key) ? state[_key] : (state[_key] = init(state));

  @override
  void set(T state, P subState) {
    state[_key] = subState;
    _setHook?.call(state, subState);
  }
}
