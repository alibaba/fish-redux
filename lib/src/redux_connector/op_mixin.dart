import '../redux/redux.dart';
import '../redux_component/basic.dart';
import '../redux_component/dependent.dart';

mixin ConnOpMixin<T, P> on AbstractConnector<T, P> {
  Dependent<T> operator +(AbstractLogic<P> logic) =>
      createDependent<T, P>(this, logic);
}
