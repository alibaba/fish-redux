import 'package:flutter/widgets.dart';

import '../../fish_redux.dart';
import '../redux/redux.dart';
import 'basic.dart';
import 'dependencies.dart';
import 'provider.dart';

/// init store's state by route-params
typedef InitState<T, P> = T Function(P params);

@immutable
abstract class Page<T, P> extends Component<T> {
  final List<Middleware<T>> _dispatchMiddleware;
  final List<ViewMiddleware<T>> _viewMiddleware;
  final List<EffectMiddleware<T>> _effectMiddleware;
  final InitState<T, P> _initState;

  List<Middleware<T>> get protectedDispatchMiddleware => _dispatchMiddleware;
  List<ViewMiddleware<T>> get protectedViewMiddleware => _viewMiddleware;
  List<EffectMiddleware<T>> get protectedEffectMiddleware => _effectMiddleware;
  InitState<T, P> get protectedinitState => _initState;

  Page({
    @required InitState<T, P> initState,
    @required ViewBuilder<T> view,
    Reducer<T> reducer,
    ReducerFilter<T> filter,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    Dependencies<T> dependencies,
    ShouldUpdate<T> shouldUpdate,
    WidgetWrapper wrapper,
    Key Function(T) key,
    List<Middleware<T>> middleware,
    List<ViewMiddleware<T>> viewMiddleware,
    List<EffectMiddleware<T>> effectMiddleware,
  })  : assert(initState != null),
        _dispatchMiddleware = middleware,
        _viewMiddleware = viewMiddleware,
        _effectMiddleware = effectMiddleware,
        _initState = initState,
        super(
          view: view,
          dependencies: dependencies,
          reducer: reducer,
          filter: filter,
          effect: effect,
          higherEffect: higherEffect,
          shouldUpdate: shouldUpdate,
          wrapper: wrapper,
          key: key,
        );

  Widget buildPage(P param, {DispatchBus bus}) {
    return protectedWrapper(_PageWidget<T>(
      component: this,
      storeBuilder: () => createMixedStore<T>(
            protectedinitState(param),
            reducer,
            storeEnhancer: applyMiddleware<T>(protectedDispatchMiddleware),
            viewEnhancer: mergeViewMiddleware<T>(protectedViewMiddleware),
            effectEnhancer: mergeEffectMiddleware<T>(protectedEffectMiddleware),
            slots: protectedDependencies?.slots,
            bus: bus,
          ),
    ));
  }
}

class _PageWidget<T> extends StatefulWidget {
  final Component<T> component;
  final Get<MixedStore<T>> storeBuilder;

  const _PageWidget({
    Key key,
    @required this.component,
    @required this.storeBuilder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageState<T>();
}

class _PageState<T> extends State<_PageWidget<T>> {
  MixedStore<T> _store;
  final Map<String, Object> extra = <String, Object>{};

  void Function() unregister;

  @override
  void initState() {
    super.initState();
    _store = widget.storeBuilder();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Register inter-page broadcast
    unregister?.call();
    unregister = _store.registerStoreReceiver((Action action) {
      _store.broadcastEffect(action);
      _store.dispatch(action);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageProvider(
      store: _store,
      extra: extra,
      child: widget.component.buildComponent(_store, _store.getState),
    );
  }

  @override
  void dispose() {
    unregister?.call();
    unregister = null;
    _store.teardown();
    super.dispose();
  }
}
