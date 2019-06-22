import 'package:flutter/widgets.dart' hide Action;

import '../../fish_redux.dart';
import '../redux/redux.dart';
import 'basic.dart';
import 'dependencies.dart';

/// init store's state by route-params
typedef InitState<T, P> = T Function(P params);

typedef StoreUpdater<T> = MixedStore<T> Function(MixedStore<T> store);

@immutable
abstract class Page<T, P> extends Component<T> {
  final List<Middleware<T>> _dispatchMiddleware;
  final List<ViewMiddleware<T>> _viewMiddleware;
  final List<EffectMiddleware<T>> _effectMiddleware;
  final List<AdapterMiddleware<T>> _adapterMiddleware;
  final InitState<T, P> _initState;

  List<Middleware<T>> get protectedDispatchMiddleware => _dispatchMiddleware;
  List<ViewMiddleware<T>> get protectedViewMiddleware => _viewMiddleware;
  List<EffectMiddleware<T>> get protectedEffectMiddleware => _effectMiddleware;
  List<AdapterMiddleware<T>> get protectedAdapterMiddleware =>
      _adapterMiddleware;
  InitState<T, P> get protectedInitState => _initState;

  final List<StoreUpdater<T>> _storeUpdaters = <StoreUpdater<T>>[];

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
    List<AdapterMiddleware<T>> adapterMiddleware,
  })  : assert(initState != null),
        _dispatchMiddleware = Collections.clone<Middleware<T>>(middleware),
        _viewMiddleware = Collections.clone<ViewMiddleware<T>>(viewMiddleware),
        _effectMiddleware =
            Collections.clone<EffectMiddleware<T>>(effectMiddleware),
        _adapterMiddleware =
            Collections.clone<AdapterMiddleware<T>>(adapterMiddleware),
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

  Widget buildPage(P param, {DispatchBus bus}) =>
      protectedWrapper(_PageWidget<T>(
        component: this,
        storeBuilder: createStoreBuilder(param, bus: bus ?? DispatchBus.shared),
      ));

  Get<MixedStore<T>> createStoreBuilder(P param, {DispatchBus bus}) =>
      () => updateStore(createMixedStore<T>(
            protectedInitState(param),
            reducer,
            storeEnhancer: applyMiddleware<T>(protectedDispatchMiddleware),
            viewEnhancer: mergeViewMiddleware<T>(protectedViewMiddleware),
            effectEnhancer: mergeEffectMiddleware<T>(protectedEffectMiddleware),
            slots: protectedDependencies?.slots,
            bus: bus,
          ));

  MixedStore<T> updateStore(MixedStore<T> store) => _storeUpdaters.fold(
        store,
        (MixedStore<T> previousValue, StoreUpdater<T> element) =>
            element(previousValue),
      );

  /// page-store connect with app-store
  void connectExtraStore<K>(Store<K> extraStore, T Function(T, K) update) =>
      _storeUpdaters.add((MixedStore<T> store) =>
          connectStores<T, K>(store, extraStore, update));

  /// inject app-middleware
  void updateMiddleware({
    void Function(List<Middleware<T>>) dispatch,
    void Function(List<ViewMiddleware<T>>) view,
    void Function(List<EffectMiddleware<T>>) effect,
    void Function(List<AdapterMiddleware<T>>) adapter,
  }) {
    dispatch?.call(_dispatchMiddleware);
    view?.call(_viewMiddleware);
    effect?.call(_effectMiddleware);
    adapter?.call(_adapterMiddleware);
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

class PageProvider extends InheritedWidget {
  final MixedStore<Object> store;

  /// Used to store page data if needed
  final Map<String, Object> extra;

  const PageProvider({
    @required this.store,
    @required this.extra,
    @required Widget child,
    Key key,
  })  : assert(store != null),
        assert(child != null),
        super(key: key, child: child);

  static PageProvider tryOf(BuildContext context) {
    final PageProvider provider =
        context.inheritFromWidgetOfExactType(PageProvider);
    return provider;
  }

  @override
  bool updateShouldNotify(PageProvider oldWidget) =>
      store != oldWidget.store && extra != oldWidget.extra;
}
