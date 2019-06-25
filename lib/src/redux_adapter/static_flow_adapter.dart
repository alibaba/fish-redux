import 'package:flutter/widgets.dart' hide Action;

import '../redux/redux.dart';
import '../redux_component/basic.dart';
import '../redux_component/logic.dart';
import '../utils/utils.dart';
import 'recycle_context.dart';

/// template is an array, driven by map like
class StaticFlowAdapter<T> extends Logic<T>
    with RecycleContextMixin<T>
    implements AbstractAdapter<T> {
  final List<Dependent<T>> _slots;

  StaticFlowAdapter({
    @required List<Dependent<T>> slots,
    Reducer<T> reducer,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    ReducerFilter<T> filter,
    Object Function(T) key,
  })  : assert(slots != null),
        _slots = Collections.compact(slots),
        super(
          reducer: combineReducers(<Reducer<T>>[
            reducer,
            combineSubReducers(
              slots.map(
                (Dependent<T> dependent) => dependent?.createSubReducer(),
              ),
            )
          ]),
          effect: effect,
          higherEffect: higherEffect,
          filter: filter,
          dependencies: null,
          key: key,
        );

  @override
  ListAdapter buildAdapter(ContextSys<T> ctx) {
    final RecycleContext<T> recycleCtx = ctx;
    final List<ListAdapter> adapters = <ListAdapter>[];

    recycleCtx.markAllUnused();
    for (int i = 0; i < _slots.length; i++) {
      final Dependent<T> dependent = _slots[i];
      final Object subObject = dependent.subGetter(recycleCtx.getState)();
      if (!dependent.isComponent()) {
        /// precondition is subObject != null
        if (subObject != null) {
          /// use index of key
          final ContextSys<Object> subCtx = recycleCtx.reuseOrCreate(i, () {
            return dependent.createContext(
              recycleCtx.store,
              recycleCtx.context,
              recycleCtx.getState,
              bus: recycleCtx.bus,
              enhancer: recycleCtx.enhancer,
            );
          });
          final ListAdapter subAdapter = dependent.buildAdapter(subCtx);
          adapters.add(subAdapter);
        }
      } else if (subObject != null) {
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
