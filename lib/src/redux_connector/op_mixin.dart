import '../redux/redux.dart';
import '../redux_component/redux_component.dart';

mixin ConnOpMixin<T, P> on AbstractConnector<T, P> {
  /// 可空 【dependent.dart#89】
  Dependent<T> operator +(AbstractLogic<P> logic) =>
      createDependent<T, P>(this, logic)!;
}
