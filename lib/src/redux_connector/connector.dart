import '../redux/redux.dart';

import '../redux_component/redux_component.dart';

/// use ConnOp<T, P> instead of Connector<T, P>
@deprecated
class Connector<T, P> extends MutableConn<T, P> {
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

class ConnOp<T, P> extends MutableConn<T, P> {
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

  Dependent<T> operator +(Logic<P> logic) => createDependent<T, P>(this, logic);
}
