import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/redux.dart';
import '../redux_component/redux_component.dart';
import '../utils/utils.dart';
import 'recycle_context.dart';

/// Use [AdapterSource] instead of [List<ItemItemBean>]
abstract class AdapterSource {
  int get itemCount;

  String getItemType(int index);

  Object getItemData(int index);

  AdapterSource updateItemData(int index, Object data, bool isStateCopied);
}

abstract class MutableSource extends AdapterSource {
  @mustCallSuper
  @override
  MutableSource updateItemData(int index, Object data, bool isStateCopied) {
    final MutableSource result = isStateCopied ? this : clone();
    return result..setItemData(index, data);
  }

  void setItemData(int index, Object data);

  MutableSource clone();
}

abstract class ImmutableSource extends AdapterSource {
  @mustCallSuper
  @override
  ImmutableSource updateItemData(int index, Object data, bool isStateCopied) =>
      setItemData(index, data);

  ImmutableSource setItemData(int index, Object data);

  ImmutableSource clone();
}

/// template is a map, driven by source
class SourceFlowAdapter<T extends AdapterSource> extends Logic<T>
    with RecycleContextMixin<T> {
  final Map<String, AbstractLogic<Object>> pool;

  SourceFlowAdapter({
    @required this.pool,
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
          reducer: _dynamicReducer(reducer, pool),
          effect: effect,
          filter: filter,
          dependencies: null,
          // ignore:deprecated_member_use_from_same_package
          key: key,
        );

  @override
  ListAdapter buildAdapter(ContextSys<T> ctx) {
    final AdapterSource adapterSource = ctx.state;
    assert(adapterSource != null);

    final RecycleContext<T> recycleCtx = ctx;
    final List<ListAdapter> adapters = <ListAdapter>[];

    recycleCtx.markAllUnused();

    for (int index = 0; index < adapterSource.itemCount; index++) {
      final String type = adapterSource.getItemType(index);
      final AbstractLogic<Object> result = pool[type];

      assert(
          result != null, 'Type of $type has not benn registered in the pool.');
      if (result != null) {
        if (result is AbstractAdapter<Object>) {
          final ContextSys<Object> subCtx = recycleCtx.reuseOrCreate(
            Tuple2<Type, Object>(
              result.runtimeType,
              result.key(adapterSource.getItemData(index)),
            ),
            () => result.createContext(
              recycleCtx.store,
              recycleCtx.context,
              _subGetter(() => recycleCtx.state, index),
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
              _subGetter(() => recycleCtx.state, index),
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
Reducer<T> _dynamicReducer<T extends AdapterSource>(
  Reducer<T> reducer,
  Map<String, AbstractLogic<Object>> pool,
) {
  final Reducer<T> dyReducer = (AdapterSource state, Action action) {
    AdapterSource copy;
    for (int i = 0; i < state.itemCount; i++) {
      final AbstractLogic<Object> result = pool[state.getItemType(i)];
      if (result != null) {
        final Object oldData = state.getItemData(i);
        final Object newData = result.onReducer(oldData, action);
        if (newData != oldData) {
          copy = state.updateItemData(i, newData, copy != null);
        }
      }
    }
    return copy ?? state;
  };

  return combineReducers(<Reducer<T>>[reducer, dyReducer]);
}

/// Define itemBean how to get state with connector
///
/// [_isSimilar] return true just use newState after reducer safely
/// [_isSimilar] return false we should use cache state before reducer invoke.
/// for reducer change state immediately but sub component will refresh on next
/// frame. in this time the sub component will use cache state.
Get<Object> _subGetter(Get<AdapterSource> getter, int index) {
  final AdapterSource curState = getter();
  String type = curState.getItemType(index);
  Object data = curState.getItemData(index);

  return () {
    final AdapterSource newState = getter();

    /// Either all sub-components use cache or not.
    if (newState != null && newState.itemCount > index) {
      final String newType = newState.getItemType(index);
      final Object newData = newState.getItemData(index);

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
