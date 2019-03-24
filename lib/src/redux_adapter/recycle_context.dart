import 'package:flutter/widgets.dart';

import '../redux/redux.dart';
import '../redux_component/context.dart';
import '../redux_component/redux_component.dart';

class RecycleContext<T> extends DefaultContext<T> {
  final Map<Object, List<ContextSys<Object>>> _cachedMap =
      <Object, List<ContextSys<Object>>>{};
  final Map<Object, int> _usedIndexMap = <Object, int>{};

  RecycleContext({
    AbstractLogic<T> factors,
    PageStore<Object> store,
    BuildContext buildContext,
    Get<T> getState,
  }) : super(
          factors: factors,
          store: store,
          buildContext: buildContext,
          getState: getState,
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

abstract class RecycleContextMixin<T> implements Logic<T> {
  @override
  RecycleContext<T> createContext({
    PageStore<Object> store,
    BuildContext buildContext,
    Get<T> getState,
  }) {
    return RecycleContext<T>(
      factors: this,
      store: store,
      buildContext: buildContext,
      getState: getState,
    );
  }
}

ListAdapter combineListAdapters(Iterable<ListAdapter> adapters) {
  final List<ListAdapter> list = adapters
      .where((ListAdapter e) => e != null && e.itemCount > 0)
      .toList(growable: false);

  if (list.every((ListAdapter e) => e.itemCount == 1)) {
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
