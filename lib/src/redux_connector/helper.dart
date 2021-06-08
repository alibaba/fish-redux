import '../redux/redux.dart';
import '../redux_component/redux_component.dart';

class ConnHelper {
  static AbstractConnector<T, K> to<T, P, K>(
      AbstractConnector<T, P> one, AbstractConnector<P, K> two) {
    return _AbstractConnector<T, P, K>(one, two);
  }

  static Dependent<T> join<T, P>(
          AbstractConnector<T, P> conn, AbstractLogic<P> logic) =>
      createDependent<T, P>(conn, logic);
}

class _AbstractConnector<T, P, K> extends AbstractConnector<T, K> {
  final AbstractConnector<T, P> one;
  final AbstractConnector<P, K> two;

  _AbstractConnector(this.one, this.two);

  @override
  K get(T state) {
    return two.get(one.get(state));
  }

  @override
  SubReducer<T> subReducer(Reducer<K> reducer) {
    return one.subReducer((P state, Action action) {
      return two.subReducer(reducer)(state, action, false);
    });
  }
}
