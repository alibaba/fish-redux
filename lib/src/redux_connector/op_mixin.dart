import '../redux/basic.dart';
import '../redux_component/basic.dart';
import '../redux_component/dependent.dart';
import '../redux_component/logic.dart';

mixin ConnOpMixin<T, P> on AbstractConnector<T, P> {
  Dependent<T> operator +(Logic<P> logic) => createDependent<T, P>(this, logic);
}
