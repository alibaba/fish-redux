import '../redux/redux.dart';
import 'op_mixin.dart';

class NoneConn<T> extends ImmutableConn<T, T> with ConnOpMixin<T, T> {
  @override
  T get(T state) => state;

  @override
  T set(T state, T subState) => subState;
}
