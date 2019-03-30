import 'connector.dart';
import 'generator.dart';

abstract class MapLike {
  Map<String, Object> _fieldsMap = <String, Object>{};

  void clear() => _fieldsMap.clear();

  Object operator [](String key) => _fieldsMap[key];

  void operator []=(String key, Object value) => _fieldsMap[key] = value;

  bool containsKey(String key) => _fieldsMap.containsKey(key);

  void copyFrom(MapLike from) =>
      _fieldsMap = <String, Object>{}..addAll(from._fieldsMap);
}

ConnOp<T, P> withMapLike<T extends MapLike, P>(String key) => ConnOp<T, P>(
      get: (T state) => state[key],
      set: (T state, P sub) => state[key] = sub,
    );

class AutoInitConnector<T extends MapLike, P> extends ConnOp<T, P> {
  static final String Function() _gen = generator();

  final String _key;
  final void Function(T state, P sub) _setHook;
  final P Function(T state) init;

  AutoInitConnector(this.init, {String key, void set(T state, P sub)})
      : assert(init != null),
        _setHook = set,
        _key = key ?? _gen();

  @override
  P get(T state) =>
      state.containsKey(_key) ? state[_key] : (state[_key] = init(state));

  @override
  void set(T state, P subState) {
    state[_key] = subState;
    _setHook?.call(state, subState);
  }
}
