import 'package:flutter/widgets.dart';

import '../redux/redux.dart';
import '../redux_component/logic.dart';
import '../redux_component/redux_component.dart';
import '../utils/utils.dart';
import 'recycle_context.dart';

/// template is an array, drived by maplike
class StaticFlowAdapter<T> extends Logic<T>
    with RecycleContextMixin<T>
    implements AbstractAdapter<T> {
  final List<Dependent<T>> _slots;

  StaticFlowAdapter({
    @required List<Dependent<T>> slots,
    Reducer<T> reducer,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    OnError<T> onError,
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
          onError: onError,
          filter: filter,
          dependencies: null,
          key: key,
        );

  ListAdapter buildAdapter2(PageStore<Object> store, Get<T> getter) {
    return null;
  }

  @override
  ListAdapter buildAdapter(
      T state, Dispatch dispatch, ViewService viewService) {
    final RecycleContext<T> ctx = viewService;
    final List<ListAdapter> adapters = <ListAdapter>[];

    ctx.markAllUnused();
    for (int i = 0; i < _slots.length; i++) {
      final Dependent<T> dependent = _slots[i];
      final Object subObject = dependent.subGetter(ctx.getState)();
      if (!dependent.isComponent()) {
        /// pred is subObject != null
        if (subObject != null) {
          /// use index of key
          final ContextSys<Object> subCtx = ctx.reuseOrCreate(i, () {
            return dependent.createContext(
              store: ctx.store,
              buildContext: ctx.context,
              getState: ctx.getState,
            );
          });
          final ListAdapter subAdapter = dependent.buildAdapter(
            subCtx.state,
            subCtx.dispatch,
            subCtx,
          );
          adapters.add(subAdapter);
        }
      } else if (subObject != null) {
        adapters.add(ListAdapter((BuildContext buildContext, int index) {
          return dependent.buildComponent(
            ctx.store,
            ctx.getState,
          );
        }, 1));
      }
    }
    ctx.cleanUnused();

    return combineListAdapters(adapters);
  }
}
