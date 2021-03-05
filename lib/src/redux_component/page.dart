import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/redux.dart';
import 'basic.dart';
import 'batch_store.dart';
import 'component.dart';
import 'dependencies.dart';
import 'dispatch_bus.dart';
import 'enhancer.dart';

/// init store's state by route-params
typedef InitState<T, P> = T Function(P params);

typedef StoreUpdater<T> = Store<T> Function(Store<T> store);

final DispatchBus sharedBus = DispatchBusDefault();

@immutable
abstract class Page<T, P> extends Component<T> {
  /// AppBus is a event-bus used to communicate between pages.
  final DispatchBus appBus = sharedBus;

  final InitState<T, P> _initState;

  final Enhancer<T> enhancer;

  /// connect with other stores
  final List<StoreUpdater<T>> _storeUpdaters = <StoreUpdater<T>>[];

  Page({
    @required InitState<T, P> initState,
    @required ViewBuilder<T> view,
    Reducer<T> reducer,
    ReducerFilter<T> filter,
    Effect<T> effect,
    Dependencies<T> dependencies,
    ShouldUpdate<T> shouldUpdate,
    WidgetWrapper wrapper,

    /// implement [StateKey] in T instead of using key in Logic.
    /// class T implements StateKey {
    ///   Object _key = UniqueKey();
    ///   Object key() => _key;
    /// }
    @deprecated Key Function(T) key,
    List<Middleware<T>> middleware,
    List<ViewMiddleware<T>> viewMiddleware,
    List<EffectMiddleware<T>> effectMiddleware,
    List<AdapterMiddleware<T>> adapterMiddleware,
  })  : assert(initState != null),
        _initState = initState,
        enhancer = EnhancerDefault<T>(
          middleware: middleware,
          viewMiddleware: viewMiddleware,
          effectMiddleware: effectMiddleware,
          adapterMiddleware: adapterMiddleware,
        ),
        super(
          view: view,
          dependencies: dependencies,
          reducer: reducer,
          filter: filter,
          effect: effect,
          shouldUpdate: shouldUpdate,
          wrapper: wrapper,
          // ignore:deprecated_member_use_from_same_package
          key: key,
        );

  Widget buildPage(P param) => protectedWrapper(_PageWidget<T, P>(
        page: this,
        param: param,
      ));

  Store<T> createStore(P param) => updateStore(createBatchStore<T>(
        _initState(param),
        reducer,
        storeEnhancer: enhancer.storeEnhance,
      ));

  Store<T> updateStore(Store<T> store) => _storeUpdaters.fold(
        store,
        (Store<T> previousValue, StoreUpdater<T> element) =>
            element(previousValue),
      );

  /// page-store connect with app-store
  void connectExtraStore<K>(
    Store<K> extraStore,

    /// To solve Reducer<Object> is neither a subtype nor a supertype of Reducer<T> issue.
    Object Function(Object, K) update,
  ) =>
      _storeUpdaters.add((Store<T> store) => connectStores<Object, K>(
            store,
            extraStore,
            update,
          ));

  DispatchBus createPageBus() => DispatchBusDefault();

  void unshift({
    List<Middleware<T>> middleware,
    List<ViewMiddleware<T>> viewMiddleware,
    List<EffectMiddleware<T>> effectMiddleware,
    List<AdapterMiddleware<T>> adapterMiddleware,
  }) {
    enhancer.unshift(
      middleware: middleware,
      viewMiddleware: viewMiddleware,
      effectMiddleware: effectMiddleware,
      adapterMiddleware: adapterMiddleware,
    );
  }

  void append({
    List<Middleware<T>> middleware,
    List<ViewMiddleware<T>> viewMiddleware,
    List<EffectMiddleware<T>> effectMiddleware,
    List<AdapterMiddleware<T>> adapterMiddleware,
  }) {
    enhancer.append(
      middleware: middleware,
      viewMiddleware: viewMiddleware,
      effectMiddleware: effectMiddleware,
      adapterMiddleware: adapterMiddleware,
    );
  }
}

class _PageWidget<T, P> extends StatefulWidget {
  final Page<T, P> page;
  final P param;

  const _PageWidget({
    Key key,
    @required this.page,
    @required this.param,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageState<T, P>();
}

class _PageState<T, P> extends State<_PageWidget<T, P>> {
  Store<T> _store;
  DispatchBus _pageBus;

  final Map<String, Object> extra = <String, Object>{};

  @override
  void initState() {
    super.initState();
    _store = widget.page.createStore(widget.param);
    _pageBus = widget.page.createPageBus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// Register inter-page broadcast
    _pageBus.attach(widget.page.appBus);
  }

  @override
  Widget build(BuildContext context) {
    // return PageProvider(
    //   store: _store,
    //   extra: extra,
    //   child:
    // );

    return widget.page.buildComponent(
      _store,
      _store.getState,
      bus: _pageBus,
      enhancer: widget.page.enhancer,
    );
  }

  @override
  void dispose() {
    _pageBus.detach();
    _store.teardown();
    super.dispose();
  }
}

@deprecated
class PageProvider extends InheritedWidget {
  final Store<Object> store;

  /// Used to store page data if needed
  final Map<String, Object> extra;

  const PageProvider({
    @required this.store,
    @required this.extra,
    @required Widget child,
    Key key,
  })  : assert(store != null),
        assert(child != null),
        super(child: child, key: key);

  static PageProvider tryOf(BuildContext context) {
    final PageProvider provider =
        context.dependOnInheritedWidgetOfExactType<PageProvider>();
    return provider;
  }

  @override
  bool updateShouldNotify(PageProvider oldWidget) =>
      store != oldWidget.store && extra != oldWidget.extra;
}
