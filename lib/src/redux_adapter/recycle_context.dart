import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/redux.dart';
import '../redux_component/redux_component.dart';
import 'adapter.dart';

class RecycleContext<T> extends AdapterContext<T> {
  final Map<Object, List<ContextSys<Object>>> _cachedMap =
      <Object, List<ContextSys<Object>>>{};
  final Map<Object, int> _usedIndexMap = <Object, int>{};

  RecycleContext({
    @required AbstractAdapter<T> logic,
    @required @required Store<Object> store,
    @required BuildContext buildContext,
    @required Get<T> getState,
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  }) : super(
          logic: logic,
          store: store,
          buildContext: buildContext,
          getState: getState,
          bus: bus,
          enhancer: enhancer,
        );

  @override
  void onLifecycle(Action action) {
    _cachedMap.forEach((Object key, List<ContextSys<Object>> list) {
      for (ContextSys<Object> sub in list) {
        sub.onLifecycle(action);
      }
    });

    super.onLifecycle(action);
  }

  void markAllUnused() {
    _usedIndexMap.clear();
  }

  ContextSys<Object> reuseOrCreate(Object key, Get<ContextSys<Object>> create) {
    final int length = _usedIndexMap[key] = (_usedIndexMap[key] ?? 0) + 1;
    final List<ContextSys<Object>> list =
        _cachedMap[key] ??= <ContextSys<Object>>[];

    if (length > list.length) {
      _cachedMap[key].add(
        create()
          ..setParent(this)
          ..onLifecycle(LifecycleCreator.initState()),
      );
    }

    return list[length - 1];
  }

  void cleanUnused() {
    _cachedMap.removeWhere((Object key, List<ContextSys<Object>> value) {
      final int usedCount = _usedIndexMap[key] ?? 0;

      for (int i = usedCount; i < value.length; i++) {
        value[i].onLifecycle(LifecycleCreator.dispose());
        value[i].dispose();
      }
      value.removeRange(usedCount, value.length);

      return usedCount == 0;
    });
  }
}

mixin RecycleContextMixin<T> implements AbstractAdapter<T> {
  @override
  RecycleContext<T> createContext(
    Store<Object> store,
    BuildContext buildContext,
    Get<T> getState, {
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  }) {
    assert(bus != null && enhancer != null);
    return RecycleContext<T>(
      logic: this,
      store: store,
      buildContext: buildContext,
      getState: getState,
      bus: bus,
      enhancer: enhancer,
    );
  }
}

ListAdapter combineListAdapters(Iterable<ListAdapter> adapters) {
  final List<ListAdapter> list = adapters
      .where((ListAdapter e) => e != null && e.itemCount > 0)
      .toList(growable: false);

  if (list.every((ListAdapter e) => e.itemCount == 1)) {
    /// The result is AbstractComponent
    return ListAdapter(
      (BuildContext buildContext, final int index) =>
          list[index].itemBuilder(buildContext, 0),
      list.length,
    );
  } else if (list.length == 1) {
    return list.single;
  }

  final int maxItemCount = list.fold(0, (int count, ListAdapter adapter) {
    return count + adapter.itemCount;
  });

  /// The result is AbstractAdapter
  return ListAdapter(
    (BuildContext buildContext, final int index) {
      assert(index >= 0 && index < maxItemCount);
      int yIndex = index;
      int xIndex = 0;
      while (xIndex < list.length && list[xIndex].itemCount <= yIndex) {
        yIndex -= list[xIndex].itemCount;
        xIndex++;
      }
      assert(xIndex < list.length);
      return list[xIndex].itemBuilder(buildContext, yIndex);
    },
    maxItemCount,
  );
}

ListAdapter memoizeListAdapter(
  AbstractAdapterBuilder<Object> result,
  ContextSys<Object> subCtx,
) {
  final Object newState = subCtx.state;
  if (subCtx.extra['@last-state'] != newState) {
    subCtx.extra['@last-state'] = newState;
    subCtx.extra['@last-adapter'] =
        _memoizeListAdapter(result.buildAdapter(subCtx));
  }

  return subCtx.extra['@last-adapter'];
}

ListAdapter _memoizeListAdapter(ListAdapter adapter) {
  if (adapter.itemCount > 0) {
    final List<Widget> memoized =
        List<Widget>.filled(adapter.itemCount, null, growable: false);
    return ListAdapter((BuildContext context, int index) {
      return (memoized[index] ??= adapter.itemBuilder(context, index));
    }, adapter.itemCount);
  } else {
    return adapter;
  }
}
