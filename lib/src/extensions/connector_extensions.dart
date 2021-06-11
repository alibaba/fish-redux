import 'package:fish_redux/fish_redux.dart';

import '../redux/redux.dart';
import '../redux_component/basic.dart';
import '../redux_connector/redux_connector.dart';

mixin IndexedConnMixin<T, P> on AbstractConnector<T, P> {
  P _cached;

  int get index;

  P getByIndex(T state, int index);

  @override
  P get(T state) {
    final P newState = getByIndex(state, index);
    return checkNextState(newState);
  }

  /// fix get 存在状态不同步
  P checkNextState(Object newState) {
    final Object lastState = _cached;
    final Object nextState =
        ((newState is! P || newState.runtimeType != lastState.runtimeType)
                ? false
                : (newState is StateKey ? newState.key() : null) ==
                    (lastState is StateKey ? lastState.key() : null))
            ? newState
            : lastState;
    return _cached = nextState;
  }
}

abstract class ImmutableIndexedConn<T, P> extends ImmutableConn<T, P>
    with ConnOpMixin<T, P>, IndexedConnMixin<T, P> {
  @override
  final int index;
  ImmutableIndexedConn(this.index);

  T setByIndex(T state, P subState, int index);

  @override
  T set(T state, P subState) => setByIndex(state, subState, index);
}

abstract class MutableIndexedConn<T, P> extends MutableConn<T, P>
    with ConnOpMixin<T, P>, IndexedConnMixin<T, P> {
  @override
  final int index;
  MutableIndexedConn(this.index);

  void setByIndex(T state, P subState, int index);

  @override
  void set(T state, P subState) => setByIndex(state, subState, index);
}

///////////////////////////////////////////////////////////////////////////////
class IndexedListConn<P> extends MutableIndexedConn<List<P>, P>
    with ConnOpMixin<List<P>, P>, IndexedConnMixin<List<P>, P> {
  IndexedListConn(int index) : super(index);

  @override
  P getByIndex(List<P> state, int index) {
    final P newState = state[index];
    return checkNextState(newState);
  }

  @override
  void setByIndex(List<P> state, Object subState, int index) {
    state[index] = subState;
  }
}

class IndexedListLikeConn<T extends MutableItemListLike>
    extends MutableIndexedConn<T, Object> with ConnOpMixin<T, Object> {
  IndexedListLikeConn(int index) : super(index);

  @override
  Object getByIndex(T state, int index) {
    final Object newState = state.getItemData(index);
    return checkNextState(newState);
  }

  @override
  void setByIndex(T state, Object subState, int index) {
    state.setItemData(index, subState);
  }
}
