import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/redux.dart';
import '../redux_component/redux_component.dart';

/// abstract for custom extends
abstract class Adapter<T> extends Logic<T> implements AbstractAdapter<T> {
  final AdapterBuilder<T> _adapter;

  AdapterBuilder<T> get protectedAdapter => _adapter;

  Adapter({
    @required AdapterBuilder<T> adapter,
    Reducer<T> reducer,
    ReducerFilter<T> filter,
    Effect<T> effect,
    Dependencies<T> dependencies,
    @deprecated Object Function(T) key,
  })  : assert(adapter != null),
        assert(dependencies?.adapter == null,
            'Unexpected dependencies.list for Adapter.'),
        _adapter = adapter,
        super(
          reducer: reducer,
          filter: filter,
          effect: effect,
          dependencies: dependencies,
          // ignore:deprecated_member_use_from_same_package
          key: key,
        );

  @override
  ListAdapter buildAdapter(ContextSys<T> ctx) =>
      ctx.enhancer
          ?.adapterEnhance(protectedAdapter, this, ctx.store)
          ?.call(ctx.state, ctx.dispatch, ctx) ??
      protectedAdapter?.call(ctx.state, ctx.dispatch, ctx);

  @override
  ContextSys<T> createContext(
    Store<Object> store,
    BuildContext buildContext,
    Get<T> getState, {
    @required Enhancer<Object> enhancer,
    @required DispatchBus bus,
  }) {
    assert(bus != null && enhancer != null);
    return AdapterContext<T>(
      logic: this,
      store: store,
      buildContext: buildContext,
      getState: getState,
      bus: bus,
      enhancer: enhancer,
    );
  }
}

class AdapterContext<T> extends LogicContext<T> {
  AdapterContext({
    @required AbstractAdapter<T> logic,
    @required Store<Object> store,
    @required BuildContext buildContext,
    @required Get<T> getState,
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  })  : assert(bus != null && enhancer != null),
        super(
          logic: logic,
          store: store,
          buildContext: buildContext,
          getState: getState,
          bus: bus,
          enhancer: enhancer,
        );

  @override
  ListAdapter buildAdapter() {
    final AbstractAdapter<T> curLogic = logic;
    return curLogic.buildAdapter(this);
  }
}
