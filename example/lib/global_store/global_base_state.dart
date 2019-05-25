import 'package:fish_redux/fish_redux.dart';
import 'package:sample/global_store/state.dart';

/// Definition of Cloneable
mixin GlobalBaseState<T extends Cloneable<T>> implements Cloneable<T> {
  T lessClone(GlobalState state);
}