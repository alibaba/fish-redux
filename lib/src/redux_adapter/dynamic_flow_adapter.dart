import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/redux.dart';
import '../redux_component/redux_component.dart';
import '../utils/utils.dart';
import 'recycle_context.dart';

class ItemBean {
  final String type;
  final Object data;

  const ItemBean(this.type, this.data);

  ItemBean clone({String type, Object data}) =>
      ItemBean(type ?? this.type, data ?? this.data);
}

/// template is a map, driven by array
/// Use [SourceFlowAdapter] instead of [DynamicFlowAdapter]
/// see in example
@deprecated
class DynamicFlowAdapter<T> extends Logic<T> with RecycleContextMixin<T> {
  final Map<String, AbstractLogic<Object>> pool;
  final AbstractConnector<T, List<ItemBean>> connector;

  DynamicFlowAdapter({
    @required this.pool,
    @required this.connector,
    ReducerFilter<T> filter,
    Reducer<T> reducer,
    Effect<T> effect,

    /// implement [StateKey] in T instead of using key in Logic.
    /// class T implements StateKey {
    ///   Object _key = UniqueKey();
    ///   Object key() => _key;
    /// }
    @deprecated Object Function(T) key,
  }) : super(
          reducer: _dynamicReducer(reducer, pool, connector),
          effect: effect,
          filter: filter,
          dependencies: null,
          // ignore:deprecated_member_use_from_same_package
          key: key,
        );

  @override
  ListAdapter buildAdapter(ContextSys<T> ctx) {
    final List<ItemBean> list = connector.get(ctx.state);
    assert(list != null);

    final RecycleContext<T> recycleCtx = ctx;
    final List<ListAdapter> adapters = <ListAdapter>[];

    recycleCtx.markAllUnused();

    for (int index = 0; index < list.length; index++) {
      final ItemBean itemBean = list[index];
      final String type = itemBean.type;
      final AbstractLogic<Object> result = pool[type];
      assert(
          result != null, 'Type of $type has not benn registered in the pool.');
      if (result != null) {
        if (result is AbstractAdapter<Object>) {
          final ContextSys<Object> subCtx = recycleCtx.reuseOrCreate(
            Tuple2<Type, Object>(
              result.runtimeType,
              result.key(itemBean.data),
            ),
            () => result.createContext(
              recycleCtx.store,
              recycleCtx.context,
              _subGetter(() => connector.get(recycleCtx.state), index),
              bus: recycleCtx.bus,
              enhancer: recycleCtx.enhancer,
            ),
          );

          /// hack to reduce adapter's rebuilding
          adapters.add(memoizeListAdapter(result, subCtx));
        } else if (result is AbstractComponent<Object>) {
          adapters.add(ListAdapter((BuildContext buildContext, int _) {
            return result.buildComponent(
              recycleCtx.store,
              _subGetter(() => connector.get(recycleCtx.state), index),
              bus: recycleCtx.bus,
              enhancer: recycleCtx.enhancer,
            );
          }, 1));
        }
      }
    }
    recycleCtx.cleanUnused();

    return combineListAdapters(adapters);
  }
}

/// Generate reducer for List<ItemBean> and combine them into one
Reducer<T> _dynamicReducer<T>(
  Reducer<T> reducer,
  Map<String, AbstractLogic<Object>> pool,
  AbstractConnector<T, List<ItemBean>> connector,
) {
  final Reducer<List<ItemBean>> dyReducer =
      (List<ItemBean> state, Action action) {
    List<ItemBean> copy;
    for (int i = 0; i < state.length; i++) {
      final ItemBean itemBean = state[i];
      final AbstractLogic<Object> result = pool[itemBean.type];
      if (result != null) {
        final Object newData = result.onReducer(itemBean.data, action);
        if (newData != itemBean.data) {
          copy ??= state.toList();
          copy[i] = itemBean.clone(data: newData);
        }
      }
    }
    return copy ?? state;
  };

  return combineReducers(<Reducer<T>>[
    reducer,
    combineSubReducers(<SubReducer<T>>[connector.subReducer(dyReducer)]),
  ]);
}

/// Define itemBean how to get state with connector
///
/// [_isSimilar] return true just use newState after reducer safely
/// [_isSimilar] return false we should use cache state before reducer invoke.
/// for reducer change state immediately but sub component will refresh on next
/// frame. in this time the sub component will use cache state.
Get<Object> _subGetter(Get<List<ItemBean>> getter, int index) {
  final List<ItemBean> curState = getter();
  ItemBean cacheItem = curState[index];

  return () {
    final List<ItemBean> newState = getter();

    /// Either all sub-components use cache or not.
    if (newState != null && newState.length > index) {
      final ItemBean newItem = newState[index];
      if (_couldReuse(cacheItem, newItem)) {
        cacheItem = newItem;
      }
    }

    return cacheItem.data;
  };
}

bool _couldReuse(ItemBean beanA, ItemBean beanB) {
  if (beanA.type != beanB.type) {
    return false;
  }

  final Object dataA = beanA.data;
  final Object dataB = beanB.data;
  if (dataA.runtimeType != dataB.runtimeType) {
    return false;
  }

  final Object keyA = dataA is StateKey ? dataA.key() : null;
  final Object keyB = dataB is StateKey ? dataB.key() : null;
  return keyA == keyB;
}
