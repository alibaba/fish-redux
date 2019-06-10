import 'package:flutter/widgets.dart';

import '../../fish_redux.dart';
import '../redux/redux.dart';
import 'basic.dart';
import 'context.dart';
import 'dependencies.dart';
import 'lifecycle.dart';
import 'logic.dart';

/// Wrapper ComponentWidget if needed like KeepAlive, RepaintBoundary etc.
typedef WidgetWrapper = Widget Function(Widget child);

@immutable
abstract class Component<T> extends Logic<T> implements AbstractComponent<T> {
  final ViewBuilder<T> _view;
  final ShouldUpdate<T> _shouldUpdate;
  final WidgetWrapper _wrapper;

  ViewBuilder<T> get protectedView => _view;
  ShouldUpdate<T> get protectedShouldUpdate => _shouldUpdate;
  WidgetWrapper get protectedWrapper => _wrapper;

  Component({
    @required ViewBuilder<T> view,
    Reducer<T> reducer,
    ReducerFilter<T> filter,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    Dependencies<T> dependencies,
    ShouldUpdate<T> shouldUpdate,
    WidgetWrapper wrapper,
    Key Function(T) key,
  })  : assert(view != null),
        _view = view,
        _wrapper = wrapper ?? _wrapperByDefault,
        _shouldUpdate = shouldUpdate ?? updateByDefault<T>(),
        super(
          reducer: reducer,
          filter: filter,
          effect: effect,
          higherEffect: higherEffect,
          dependencies: dependencies,
          key: key,
        );

  @override
  Widget buildComponent(MixedStore<Object> store, Get<Object> getter) {
    return protectedWrapper(
      ComponentWidget<T>(
        component: this,
        getter: _asGetter<T>(getter),
        store: store,
        key: key(getter()),
      ),
    );
  }

  @override
  ViewUpdater<T> createViewUpdater(
    ContextSys<T> ctx,
    void Function() markNeedsBuild,
  ) =>
      _ViewUpdater<T>(
        view: ctx.store.viewEnhance(protectedView, this),
        ctx: ctx,
        markNeedsBuild: markNeedsBuild,
        shouldUpdate: protectedShouldUpdate,
        name: name,
      );

  @override
  ContextSys<T> createContext({
    MixedStore<Object> store,
    BuildContext buildContext,
    Get<T> getState,
  }) {
    /// init context
    final ContextSys<T> mainCtx = super.createContext(
      store: store,
      buildContext: buildContext,
      getState: getState,
    );

    final ContextSys<T> sidecarCtx =
        protectedDependencies?.adapter?.createContext(
      store: store,
      buildContext: buildContext,
      getState: getState,
    );

    /// adapter-effect-promote
    return mergeContext(mainCtx, sidecarCtx);
  }

  ComponentState<T> createState() => ComponentState<T>();

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
  final void Function() markNeedsBuild;
  final ShouldUpdate<T> shouldUpdate;
  final String name;
  final ContextSys<T> ctx;

  Widget _widgetCache;
  T _latestState;

  _ViewUpdater({
    @required this.view,
    @required this.ctx,
    @required this.markNeedsBuild,
    @required this.shouldUpdate,
    this.name,
  })  : assert(view != null),
        assert(shouldUpdate != null),
        assert(ctx != null),
        assert(markNeedsBuild != null),
        _latestState = ctx.state;

  @override
  Widget buildWidget() {
    Widget result = _widgetCache;
    if (result == null) {
      result = _widgetCache = view(ctx.state, ctx.dispatch, ctx);

      ctx.dispatch(LifecycleCreator.build(name));
    }
    return result;
  }

  @override
  void didUpdateWidget() {
    final T now = ctx.state;
    if (shouldUpdate(_latestState, now)) {
      _widgetCache = null;
      _latestState = now;
    }
  }

  @override
  void onNotify() {
    final T now = ctx.state;
    if (shouldUpdate(_latestState, now)) {
      _widgetCache = null;

      markNeedsBuild();

      _latestState = now;
    }
  }

  @override
  void reassemble() {
    _widgetCache = null;
  }

  @override
  void forceUpdate() {
    _widgetCache = null;

    try {
      markNeedsBuild();
    } catch (e) {
      /// TODO
      /// should try-catch in force mode which is called from outside
    }
  }
}

class ComponentWidget<T> extends StatefulWidget {
  final Component<T> component;
  final MixedStore<Object> store;
  final Get<T> getter;

  const ComponentWidget({
    @required this.component,
    @required this.store,
    @required this.getter,
    Key key,
  })  : assert(component != null),
        assert(store != null),
        assert(getter != null),
        super(key: key);

  @override
  ComponentState<T> createState() => component.createState();
}

class ComponentState<T> extends State<ComponentWidget<T>> {
  ContextSys<T> mainCtx;
  ViewUpdater<T> viewUpdater;

  @mustCallSuper
  @override
  Widget build(BuildContext context) => viewUpdater.buildWidget();

  @override
  @protected
  @mustCallSuper
  void reassemble() {
    super.reassemble();
    viewUpdater.reassemble();
    mainCtx.onLifecycle(LifecycleCreator.reassemble());
  }

  @mustCallSuper
  @override
  void initState() {
    super.initState();

    /// init context
    mainCtx = widget.component.createContext(
      store: widget.store,
      buildContext: context,
      getState: () => widget.getter(),
    );

    viewUpdater = widget.component.createViewUpdater(mainCtx, () {
      if (mounted) {
        setState(() {});
      }
    });

    //// force update if driven from outside
    mainCtx.bindForceUpdate(() {
      viewUpdater.forceUpdate();
    });

    /// register store.subscribe
    mainCtx.registerOnDisposed(
        widget.store.subscribe(() => viewUpdater.onNotify()));

    mainCtx.onLifecycle(LifecycleCreator.initState());
  }

  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mainCtx.onLifecycle(LifecycleCreator.didChangeDependencies());
  }

  @mustCallSuper
  @override
  void deactivate() {
    super.deactivate();
    mainCtx.onLifecycle(LifecycleCreator.deactivate());
  }

  @mustCallSuper
  @override
  void didUpdateWidget(ComponentWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    viewUpdater.didUpdateWidget();
    mainCtx.onLifecycle(LifecycleCreator.didUpdateWidget());
  }

  @mustCallSuper
  @override
  void dispose() {
    mainCtx
      ..onLifecycle(LifecycleCreator.dispose())
      ..dispose();
    super.dispose();
  }
}
