import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/widgets.dart' hide Action, Page;
import '../redux/redux.dart';
import '../redux_component/redux_component.dart';
import 'recycle_context.dart';

class FlowAdapter<T> extends Logic<T>
    with RecycleContextMixin<T>
    implements AbstractAdapter<T> {
  final FlowDependencies<T> _flowDependencies;
  FlowAdapter({
    @required FlowAdapterView<T> view,
    ReducerFilter<T> filter,
    Reducer<T> reducer,
    Effect<T> effect,
    @deprecated Object Function(T state) key,
  })  : assert(view != null),
        _flowDependencies =
            FlowDependencies<T>(_memoize<T, DependentArray<T>>(view)),
        super(
          reducer: reducer,
          effect: effect,
          filter: filter,
          dependencies: null,
          // ignore: deprecated_member_use_from_same_package
          key: key,
        );

  @override
  Reducer<T> get protectedDependenciesReducer =>_flowDependencies.createReducer();

  @override
  ListAdapter buildAdapter(ContextSys<T> ctx) {
    final T state = ctx.state;
    final DependentArray<T> depArray = _flowDependencies.build(state);

    final RecycleContext<T> recycleCtx = ctx;
    final List<ListAdapter> adapters = <ListAdapter>[];

    recycleCtx.markAllUnused();

    final int count = depArray.length;
    for (int index = 0; index < count; index++) {
      final Dependent<T> dependent = depArray[index];

      if (dependent == null) {
        continue;
      }

      if (dependent.isAdapter()) {
        /// use dependent's key
        final ContextSys<Object> subCtx = recycleCtx.reuseOrCreate(
          dependent.key(state),
          () {
            return dependent.createContext(
              recycleCtx.store,
              recycleCtx.context,
              recycleCtx.getState,
              bus: recycleCtx.bus,
              enhancer: recycleCtx.enhancer,
            );
          },
        );

        adapters.add(dependent.buildAdapter(subCtx));
      } else if (dependent.isComponent()) {
        adapters.add(ListAdapter((BuildContext buildContext, int index) {
          return dependent.buildComponent(
            recycleCtx.store,
            recycleCtx.getState,
            bus: recycleCtx.bus,
            enhancer: recycleCtx.enhancer,
          );
        }, 1));
      }
    }
    recycleCtx.cleanUnused();

    return combineListAdapters(adapters);
  }
}

//////////////////////////////////////////
typedef IndexedDependentBuilder<T> = Dependent<T> Function(int);

class DependentArray<T> {
  final IndexedDependentBuilder<T> builder;
  final int length;

  DependentArray({@required this.builder, @required this.length})
      : assert(builder != null && length >= 0);

  DependentArray.fromList(List<Dependent<T>> list)
      : this(builder: (int index) => list[index], length: list.length);

  Dependent<T> operator [](int index) => builder(index);
}

typedef FlowAdapterView<T> = DependentArray<T> Function(T);

class FlowDependencies<T> {
  final FlowAdapterView<T> build;

  const FlowDependencies(this.build);

  Reducer<T> createReducer() => (T state, Action action) {
        T copy = state;
        bool hasChanged = false;
        final DependentArray<T> list = build(state);
        if (list != null) {
          for (int i = 0; i < list.length; i++) {
            final Dependent<T> dep = list[i];
            final SubReducer<T> subReducer = dep?.createSubReducer();
            if (subReducer != null) {
              copy = subReducer(copy, action, hasChanged);
              hasChanged = hasChanged || copy != state;
            }
          }
        }
        return copy;
      };
}

//////////////////////////////////////////
/// Use [ItemListLike] instead of [List<ItemItemBean>]
abstract class ItemListLike {
  int get itemCount;

  String getItemType(int index);

  Object getItemData(int index);

  ItemListLike updateItemData(int index, Object data, bool isStateCopied);
}

abstract class MutableItemListLike extends ItemListLike {
  @mustCallSuper
  @override
  MutableItemListLike updateItemData(
      int index, Object data, bool isStateCopied) {
    final MutableItemListLike result = isStateCopied ? this : clone();
    return result..setItemData(index, data);
  }

  void setItemData(int index, Object data);

  MutableItemListLike clone();
}

abstract class ImmutableItemListLike extends ItemListLike {
  @mustCallSuper
  @override
  ImmutableItemListLike updateItemData(
          int index, Object data, bool isStateCopied) =>
      setItemData(index, data);

  ImmutableItemListLike setItemData(int index, Object data);

  ImmutableItemListLike clone();
}

//////////////////////////////////////////
class ItemBean {
  final String type;
  final Object data;

  const ItemBean(this.type, this.data);

  ItemBean clone({String type, Object data}) =>
      ItemBean(type ?? this.type, data ?? this.data);
}

/// Optimize flow-adapter-view performance
R Function(P) _memoize<P, R>(R Function(P) functor) {
  bool hasInvoked = false;
  P cahcedKey;
  R cachedValue;
  return (P param) {
    if (!hasInvoked) {
      hasInvoked = true;
      cahcedKey = param;
      cachedValue = functor(param);
    } else if (param != cahcedKey) {
      cahcedKey = param;
      cachedValue = functor(param);
    }
    return cachedValue;
  };
}
