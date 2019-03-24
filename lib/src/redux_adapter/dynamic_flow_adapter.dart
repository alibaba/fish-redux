import 'package:flutter/widgets.dart';

import '../redux/redux.dart';
import '../redux_component/logic.dart';
import '../redux_component/redux_component.dart';
import '../utils/utils.dart';
import 'recycle_context.dart';

abstract class ItemBean implements Cloneable<ItemBean> {
  String get type;
  set type(String type);
  Object get data;
  set data(Object data);

  factory ItemBean(String type, Object data) => _ItemBean(type, data);
}

class _ItemBean implements ItemBean {
  @override
  String type;
  @override
  Object data;

  _ItemBean(this.type, this.data);

  @override
  _ItemBean clone() => _ItemBean(type, data);
}

/// template is a map, driven by array
class DynamicFlowAdapter<T> extends Logic<T>
    with RecycleContextMixin<T>
    implements AbstractAdapter<T> {
  final Map<String, AbstractLogic<Object>> pool;
  final Connector<T, List<ItemBean>> connector;

  DynamicFlowAdapter({
    @required this.pool,
    @required this.connector,
    ReducerFilter<T> filter,
    Reducer<T> reducer,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    OnError<T> onError,
    Object Function(T) key,
  }) : super(
          reducer: _dynamicReducer(reducer, pool, connector),
          effect: effect,
          higherEffect: higherEffect,
          onError: onError,
          filter: filter,
          dependencies: null,
          key: key,
        );

  @override
  ListAdapter buildAdapter(
    T state,
    Dispatch dispatch,
    ViewService viewService,
  ) {
    final List<ItemBean> list = connector.get(state);
    assert(list != null);

    final RecycleContext<T> ctx = viewService;
    final List<ListAdapter> adapters = <ListAdapter>[];

    ctx.markAllUnused();

    for (int index = 0; index < list.length; index++) {
      final ItemBean itemBean = list[index];
      final String type = itemBean.type;
      final AbstractLogic<Object> result = pool[type];
      assert(
          result != null, 'Type of $type has not benn registered in the pool.');
      if (result != null) {
        if (result is AbstractAdapter<Object>) {
          final ContextSys<Object> subCtx = ctx.reuseOrCreate(
            Tuple2<Type, Object>(
              result.runtimeType,
              result.key(itemBean.data),
            ),
            () {
              return result.createContext(
                store: ctx.store,
                buildContext: ctx.context,
                getState: _subGetter(() => connector.get(ctx.state), index),
              );
            },
          );
          adapters.add(result.buildAdapter(
            subCtx.state,
            subCtx.dispatch,
            subCtx,
          ));
        } else if (result is AbstractComponent<Object>) {
          adapters.add(ListAdapter((BuildContext buildContext, int _) {
            return result.buildComponent(
              ctx.store,
              _subGetter(() => connector.get(ctx.state), index),
            );
          }, 1));
        }
      }
    }
    ctx.cleanUnused();

    return combineListAdapters(adapters);
  }
}

Reducer<T> _dynamicReducer<T>(
  Reducer<T> reducer,
  Map<String, AbstractLogic<Object>> pool,
  Connector<T, List<ItemBean>> connector,
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
          copy[i] = itemBean.clone()..data = newData;
        }
      }
    }
    return copy ?? state;
  };

  return combineReducers(<Reducer<T>>[
    reducer,
    combineSubReducers(<SubReducer<T>>[subReducer(connector, dyReducer)]),
  ]);
}

Get<Object> _subGetter(Get<List<ItemBean>> getter, int index) {
  final List<ItemBean> curState = getter();
  final Object subCache = curState[index].data;
  return () {
    final List<ItemBean> newState = getter();

    /// Either all sub-components use cache or not.
    if (_isSimilar(curState, newState)) {
      return newState[index].data;
    } else {
      return subCache;
    }
  };
}

bool _isSimilar(
  List<ItemBean> oldList,
  List<ItemBean> newList,
) {
  if (oldList != newList &&
      oldList?.length == newList.length &&
      Collections.isNotEmpty(newList)) {
    bool isEvery = true;
    for (int i = 0; i < newList.length; i++) {
      if (oldList[i].type != newList[i].type ||
          oldList[i].data.runtimeType != newList[i].data.runtimeType) {
        isEvery = false;
        break;
      }
    }
    return isEvery;
  }
  return false;
}
