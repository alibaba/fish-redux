import 'package:flutter/widgets.dart';

import '../../fish_redux.dart';
import '../redux/redux.dart';
import '../utils/utils.dart';
import 'basic.dart';
import 'context.dart';
import 'debug_or_report.dart';
import 'dependencies.dart';
import 'lifecycle.dart';
import 'logic.dart';
import 'page_store.dart';
import 'provider.dart';

/// Wrapper ComponentWidget if needed like KeepAlive, RepaintBoundary etc.
typedef WidgetWrapper = Widget Function(Widget child);

@immutable
abstract class Component<T> extends Logic<T> implements AbstractComponent<T> {
  final ViewBuilder<T> view;
  final ShouldUpdate<T> shouldUpdate;
  final WidgetWrapper wrapper;

  Component({
    @required this.view,
    Reducer<T> reducer,
    ReducerFilter<T> filter,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    OnError<T> onError,
    Dependencies<T> dependencies,
    ShouldUpdate<T> shouldUpdate,
    WidgetWrapper wrapper,
    Key Function(T) key,
  })  : assert(view != null),
        wrapper = wrapper ?? _wrapperByDefault,
        shouldUpdate = shouldUpdate ?? updateByDefault<T>(),
        super(
          reducer: reducer,
          filter: filter,
          effect: effect,
          higherEffect: higherEffect,
          onError: onError,
          dependencies: dependencies,
          key: key,
        );

  @override
  Widget buildComponent(PageStore<Object> store, Get<Object> getter) {
    return wrapper(
      _ComponentWidget<T>(
        component: this,
        getter: _asGetter<T>(getter),
        store: store,
        key: key(getter()),
      ),
    );
  }

  ViewBuilder<T> createViewBuilder() {
    return isDebug()
        ? view
        : (T state, Dispatch dispatch, ViewService viewService) {
            Widget result;
            try {
              result = view(state, dispatch, viewService);
            } catch (e, stackTrace) {
              /// the upper layer decides how to consume the error.
              dispatch($DebugOrReportCreator.reportBuildError(e, stackTrace));
              result = Container();
            }
            return result;
          };
  }

  @override
  ViewUpdater<T> createViewUpdater(T init) =>
      _ViewUpdater<T>(createViewBuilder(), shouldUpdate, name, init);

  @override
  ContextSys<T> createContext({
    PageStore<Object> store,
    Get<BuildContext> getBuildContext,
    Get<T> getState,
  }) {
    /// init context
    final ContextSys<T> mainCtx = super.createContext(
      store: store,
      getBuildContext: getBuildContext,
      getState: getState,
    );

    final ContextSys<T> sidecarCtx = dependencies?.adapter?.createContext(
      store: store,
      getBuildContext: getBuildContext,
      getState: getState,
    );

    /// adapter-effect-promote
    return mergeContext(mainCtx, sidecarCtx);
  }

  String get name => cache<String>('name', () => runtimeType.toString());

  static ShouldUpdate<K> neverUpdate<K>() => (K _, K __) => false;

  static ShouldUpdate<K> alwaysUpdate<K>() => (K _, K __) => true;

  static ShouldUpdate<K> updateByDefault<K>() =>
      (K _, K __) => !identical(_, __);

  static Widget _wrapperByDefault(Widget child) => child;

  static Get<T> _asGetter<T>(Get<Object> getter) {
    Get<T> runtimeGetter;
    if (getter is Get<T>) {
      runtimeGetter = getter;
    } else {
      runtimeGetter = () {
        final T result = getter();
        return result;
      };
    }
    return runtimeGetter;
  }
}

class _ViewUpdater<T> implements ViewUpdater<T> {
  final ViewBuilder<T> view;
  final ShouldUpdate<T> shouldUpdate;
  final String name;

  Widget _widgetCache;
  T _latestState;

  _ViewUpdater(this.view, this.shouldUpdate, this.name, this._latestState)
      : assert(view != null),
        assert(shouldUpdate != null);

  @override
  Widget buildView(T state, Dispatch dispatch, ViewService viewService) {
    if (_widgetCache == null) {
      _widgetCache = view(state, dispatch, viewService);

      dispatch(LifecycleCreator.build());

      /// to watch component's update in debug-mode
      assert(() {
        dispatch($DebugOrReportCreator.debugUpdate(name));
        return true;
      }());
    }
    return _widgetCache;
  }

  @override
  void onNotify(T now, void Function() markNeedsBuild, Dispatch dispatch) {
    if (shouldUpdate(_latestState, now)) {
      _widgetCache = null;
      try {
        markNeedsBuild();
      } on FlutterError catch (e) {
        /// 应该区分不同模式下的处理策略？
        dispatch(
            $DebugOrReportCreator.reportSetStateError(e, StackTrace.current));
      }

      _latestState = now;
    }
  }
}

class _ComponentWidget<T> extends StatefulWidget {
  final Component<T> component;
  final PageStore<Object> store;
  final Get<T> getter;

  const _ComponentWidget({
    @required this.component,
    @required this.store,
    @required this.getter,
    Broadcast broadcast,
    Key key,
  })  : assert(store != null && getter != null),
        super(key: key);

  @override
  _ComponentState<T> createState() => _ComponentState<T>();
}

class _ComponentState<T> extends State<_ComponentWidget<T>> {
  ContextSys<T> _mainCtx;
  ViewUpdater<T> _viewUpdater;

  @override
  Widget build(BuildContext context) =>
      _viewUpdater.buildView(_mainCtx.state, _mainCtx.dispatch, _mainCtx);

  @override
  void initState() {
    super.initState();

    /// init context
    _mainCtx = widget.component.createContext(
      store: widget.store,
      getBuildContext: () => context,
      getState: () => widget.getter(),
    );

    _viewUpdater = widget.component.createViewUpdater(_mainCtx.state);

    /// register store.subscribe
    _mainCtx
      ..registerOnDisposed(widget.store.subscribe(_onNotify))
      ..onLifecycle(LifecycleCreator.initState());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainCtx.onLifecycle(LifecycleCreator.didChangeDependencies());
  }

  @override
  void deactivate() {
    super.deactivate();
    _mainCtx.onLifecycle(LifecycleCreator.deactivate());
  }

  @override
  void didUpdateWidget(_ComponentWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _onNotify();
    _mainCtx.onLifecycle(LifecycleCreator.didUpdateWidget());
  }

  @override
  void dispose() {
    _mainCtx
      ..onLifecycle(LifecycleCreator.dispose())
      ..dispose();
    super.dispose();
  }

  void _onNotify() {
    _viewUpdater.onNotify(_mainCtx.state, () {
      if (mounted) {
        setState(() {});
      }
    }, _mainCtx.dispatch);
  }
}

/// init store's state by route-params
typedef InitState<T extends Cloneable<T>, P> = T Function(P params);

@immutable
abstract class Page<T extends Cloneable<T>, P> extends Component<T> {
  final List<Middleware<T>> middlewares;
  final InitState<T, P> initState;

  Page({
    @required this.initState,
    this.middlewares,
    @required ViewBuilder<T> view,
    Reducer<T> reducer,
    ReducerFilter<T> filter,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    OnError<T> onError,
    Dependencies<T> dependencies,
    ShouldUpdate<T> shouldUpdate,
    WidgetWrapper wrapper,
    Key Function(T) key,
  })  : assert(initState != null),
        super(
          view: view,
          dependencies: dependencies,
          reducer: reducer,
          filter: filter,
          effect: effect,
          higherEffect: higherEffect,
          onError: onError,
          shouldUpdate: shouldUpdate,
          wrapper: wrapper,
          key: key,
        );

  /// Expansion capability
  List<Middleware<T>> buildMiddlewares(List<Middleware<T>> middlewares) {
    return Collections.merge<Middleware<T>>(
        <Middleware<T>>[interrupt$<T>()], middlewares);
  }

  Widget buildPage(P param) {
    return wrapper(_PageWidget<T>(
      component: this,
      storeBuilder: () => createPageStore<T>(
            initState(param),
            reducer,
            applyMiddleware<T>(buildMiddlewares(middlewares)),
          ),
    ));
  }

  static Middleware<T> interrupt$<T>() {
    return ({Dispatch dispatch, Get<T> getState}) {
      return (Dispatch next) {
        return (Action action) {
          if (!shouldBeInterrupttedBeforeReducer(action)) {
            next(action);
          }
        };
      };
    };
  }
}

class _PageWidget<T> extends StatefulWidget {
  final Component<T> component;
  final Get<PageStore<T>> storeBuilder;

  const _PageWidget({
    Key key,
    @required this.component,
    @required this.storeBuilder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageState<T>();
}

class _PageState<T> extends State<_PageWidget<T>> {
  PageStore<T> _store;
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
    unregister = AppProvider.register(context, _store.sendBroadcast);
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
    super.dispose();
  }
}
