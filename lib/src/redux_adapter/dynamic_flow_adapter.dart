import 'package:flutter/widgets.dart' hide Action;

import '../redux/redux.dart';
import '../redux_component/redux_component.dart';
import '../utils/utils.dart';
import 'recycle_context.dart';

/// Use [AdapterSource] instead of [List<ItemBean>]
// @deprecated
class ItemBean {
  final String type;
  final Object data;

  const ItemBean(this.type, this.data);

  ItemBean clone({String type, Object data}) =>
      ItemBean(type ?? this.type, data ?? this.data);
}

abstract class AdapterSource {
  int get itemCount;

  String getType(int index);

  Object getData(int index);

  AdapterSource update(int index, Object data, bool isStateCopied);
}

abstract class MutableSource extends AdapterSource {
  @mustCallSuper
  @override
  MutableSource update(int index, Object data, bool isStateCopied) {
    final MutableSource result = isStateCopied ? this : clone();
    return result..setData(index, data);
  }

  void setData(int index, Object data);

  MutableSource clone();
}

abstract class ImmutableSource extends AdapterSource {
  @mustCallSuper
  @override
  ImmutableSource update(int index, Object data, bool isStateCopied) =>
      setData(index, data);

  ImmutableSource setData(int index, Object data);

  ImmutableSource clone();
}

class _Conn<T> implements AbstractConnector<T, AdapterSource> {
  final AbstractConnector<T, List<ItemBean>> connector;

  _Conn(this.connector);

  @override
  AdapterSource get(T state) => _ListSource(connector.get(state));

  @override
  SubReducer<T> subReducer(Reducer<AdapterSource> reducer) {
    return connector.subReducer((List<ItemBean> list, Action action) {
      /// maybe a long loop
      final _ListSource listSource = reducer(_ListSource(list), action);
      return listSource.list;
    });
  }
}

class _ListSource extends MutableSource {
  /// ignore:deprecated_member_use_from_same_package
  final List<ItemBean> list;

  _ListSource(this.list);

  @override
  MutableSource clone() => _ListSource(list.toList());

  @override
  Object getData(int index) => list[index].data;

  @override
  String getType(int index) => list[index].type;

  @override
  int get itemCount => list.length;

  @override
  void setData(int index, Object data) =>
      list[index] = ItemBean(list[index].type, data);
}

/// template is a map, driven by array
class DynamicFlowAdapter<T> extends Logic<T> with RecycleContextMixin<T> {
  final Map<String, AbstractLogic<Object>> pool;

  final AbstractConnector<T, AdapterSource> sourceConn;

  DynamicFlowAdapter({
    @required this.pool,

    /// ignore:deprecated_member_use_from_same_package
    @deprecated AbstractConnector<T, List<ItemBean>> connector,
    @required AbstractConnector<T, AdapterSource> sourceConn2,
    ReducerFilter<T> filter,
    Reducer<T> reducer,
    Effect<T> effect,

    /// implement [StateKey] in T instead of using key in Logic.
    /// class T implements StateKey {
    ///   Object _key = UniqueKey();
    ///   Object key() => _key;
    /// }
    @deprecated Object Function(T) key,
  })  : sourceConn = sourceConn2 ?? _Conn<T>(connector),
        super(
          reducer: _dynamicReducer(
              reducer, pool, sourceConn2 ?? _Conn<T>(connector)),
          effect: effect,
          filter: filter,
          dependencies: null,
          // ignore:deprecated_member_use_from_same_package
          key: key,
        );

  @override
  ListAdapter buildAdapter(ContextSys<T> ctx) {
    final AdapterSource adapterSource = sourceConn.get(ctx.state);
    assert(adapterSource != null);

    final RecycleContext<T> recycleCtx = ctx;
    final List<ListAdapter> adapters = <ListAdapter>[];

    recycleCtx.markAllUnused();

    for (int index = 0; index < adapterSource.itemCount; index++) {
      final String type = adapterSource.getType(index);
      final AbstractLogic<Object> result = pool[type];

      assert(
          result != null, 'Type of $type has not benn registered in the pool.');
      if (result != null) {
        if (result is AbstractAdapter<Object>) {
          final ContextSys<Object> subCtx = recycleCtx.reuseOrCreate(
            Tuple2<Type, Object>(
              result.runtimeType,
              result.key(adapterSource.getData(index)),
            ),
            () => result.createContext(
              recycleCtx.store,
              recycleCtx.context,
              _subGetter(() => sourceConn.get(recycleCtx.state), index),
              bus: recycleCtx.bus,
              enhancer: recycleCtx.enhancer,
            ),
          );
          adapters.add(result.buildAdapter(subCtx));
        } else if (result is AbstractComponent<Object>) {
          adapters.add(ListAdapter((BuildContext buildContext, int _) {
            return result.buildComponent(
              recycleCtx.store,
              _subGetter(() => sourceConn.get(recycleCtx.state), index),
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
  AbstractConnector<T, AdapterSource> connector,
) {
  final Reducer<AdapterSource> dyReducer =
      (AdapterSource state, Action action) {
    AdapterSource copy;
    for (int i = 0; i < state.itemCount; i++) {
      final AbstractLogic<Object> result = pool[state.getType(i)];
      if (result != null) {
        final Object oldData = state.getData(i);
        final Object newData = result.onReducer(oldData, action);
        if (newData != oldData) {
          copy = state.update(i, newData, copy != null);
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
Get<Object> _subGetter(Get<AdapterSource> getter, int index) {
  final AdapterSource curState = getter();
  String type = curState.getType(index);
  Object data = curState.getData(index);

  return () {
    final AdapterSource newState = getter();

    /// Either all sub-components use cache or not.
    if (newState != null && newState.itemCount > index) {
      final String newType = newState.getType(index);
      final Object newData = newState.getData(index);

      if (_couldReuse(
        typeA: type,
        typeB: newType,
        dataA: data,
        dataB: newData,
      )) {
        type = newType;
        data = newData;
      }
    }

    return data;
  };
}

bool _couldReuse({String typeA, String typeB, Object dataA, Object dataB}) {
  return typeA != typeB
      ? false
      : dataA.runtimeType != dataB.runtimeType
          ? false
          : (dataA is StateKey ? dataA.key() : null) ==
              (dataB is StateKey ? dataB.key() : null);
}
