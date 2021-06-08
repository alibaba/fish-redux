import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/foundation.dart';

import '../redux/basic.dart';
import '../redux_adapter/redux_adapter.dart';
import '../redux_component/redux_component.dart';
import '../redux_connector/redux_connector.dart';
import 'connector_extensions.dart';

class SimpleFlowAdapter<T> extends FlowAdapter<T> {
  SimpleFlowAdapter({
    @required FlowAdapterView<T> view,
    ReducerFilter<T> filter,
    Reducer<T> reducer,
    Effect<T> effect,
    @deprecated Object Function(T state) key,
  }) : super(
          view: view,
          filter: filter,
          reducer: reducer,
          effect: effect,
          key: key,
        );

  SimpleFlowAdapter.static({
    @required List<Dependent<T>> children,
    ReducerFilter<T> filter,
    Reducer<T> reducer,
    Effect<T> effect,
    @deprecated Object Function(T state) key,
  }) : this(
          view: _buildByStatic(children),
          filter: filter,
          reducer: reducer,
          effect: effect,
          key: key,
        );

  SimpleFlowAdapter.dynamic({
    @required Map<String, AbstractLogic<Object>> pool,
    @required AbstractConnector<T, List<ItemBean>> connector,
    ReducerFilter<T> filter,
    Reducer<T> reducer,
    Effect<T> effect,
    @deprecated Object Function(T state) key,
  }) : this(
          view: _buildByDynamic(pool: pool, connector: connector),
          filter: filter,
          reducer: reducer,
          effect: effect,
          key: key,
        );

  SimpleFlowAdapter.listLike({
    @required Map<String, AbstractLogic<Object>> pool,
    @required AbstractConnector<T, MutableItemListLike> connector,
    ReducerFilter<T> filter,
    Reducer<T> reducer,
    Effect<T> effect,
    @deprecated Object Function(T state) key,
  }) : this(
          view: _buildByListLike(pool: pool, connector: connector),
          filter: filter,
          reducer: reducer,
          effect: effect,
          key: key,
        );
}

FlowAdapterView<T> _buildByStatic<T>(List<Dependent<T>> children) {
  return (T state) {
    return DependentArray<T>.fromList(children
        .where((Dependent<T> dep) => dep.subGetter(() => state).call() != null)
        .toList());
  };
}

FlowAdapterView<T> _buildByListLike<T>({
  @required Map<String, AbstractLogic<Object>> pool,
  @required AbstractConnector<T, MutableItemListLike> connector,
}) {
  return (T state) {
    final MutableItemListLike source = connector.get(state);
    final DependentArray<T> depList = DependentArray<T>(
      length: source.itemCount,
      builder: (int index) {
        final String type = source.getItemType(index);
        final Dependent<T> dep = ConnHelper.join(
          ConnHelper.to(
            connector,
            IndexedListLikeConn<MutableItemListLike>(index),
          ),
          pool[type],
        );
        return dep;
      },
    );
    return depList;
  };
}

FlowAdapterView<T> _buildByDynamic<T>({
  @required Map<String, AbstractLogic<Object>> pool,
  @required AbstractConnector<T, List<ItemBean>> connector,
}) {
  return (T state) {
    final List<ItemBean> list = connector.get(state);
    final DependentArray<T> depList = DependentArray<T>(
      length: list.length,
      builder: (int index) {
        assert(index < list.length);
        if (index < list.length) {
          final ItemBean ib = list[index];
          assert(ib != null);
          return ConnHelper.join<T, Object>(
            ConnHelper.to<T, List<ItemBean>, Object>(
              connector,
              IndexedListConn<ItemBean>(index),
            ),
            pool[ib.type],
          );
        }
        return null;
      },
    );
    return depList;
  };
}
