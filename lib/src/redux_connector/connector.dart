import '../redux/redux.dart';

import 'op_mixin.dart';

class ConnOp<T, P> extends MutableConn<T, P> with ConnOpMixin<T, P> {
  final P Function(T)? _getter;
  final void Function(T, P)? _setter;

  const ConnOp({
    P Function(T)? get,
    void Function(T, P)? set,
  })  : _getter = get,
        _setter = set;

  /// 可空
  @override
  P? get(T? state) => state != null ? _getter?.call(state) : null;

  @override
  void set(T state, P subState) => _setter?.call(state, subState);
}
