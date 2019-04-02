import '../redux/redux.dart';
import '../redux_component/redux_component.dart';

mixin ConnOpMixin<T, P> on AbstractConnector<T, P> {
  Dependent<T> operator +(Logic<P> logic) => createDependent<T, P>(this, logic);
}
