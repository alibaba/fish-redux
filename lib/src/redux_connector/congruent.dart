import '../redux/redux.dart';
import '../redux_component/redux_component.dart';

class CongruentConn<T> extends ImmutableConn<T, T> {
  @override
  T get(T state) => state;

  @override
  T set(T state, T subState) => subState;

  Dependent<T> operator +(Logic<T> logic) => createDependent<T, T>(this, logic);
}
