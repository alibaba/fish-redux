import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/basic.dart';
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
  final bool _clearOnDependenciesChanged;

  ViewBuilder<T> get protectedView => _view;
  ShouldUpdate<T> get protectedShouldUpdate => _shouldUpdate;
  WidgetWrapper get protectedWrapper => _wrapper;
  bool get protectedClearOnDependenciesChanged => _clearOnDependenciesChanged;

  Component({
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
    bool clearOnDependenciesChanged = false,
  })  : assert(view != null),
        _view = view,
        _wrapper = wrapper ?? _wrapperByDefault,
        _shouldUpdate = shouldUpdate ?? updateByDefault<T>(),
        _clearOnDependenciesChanged = clearOnDependenciesChanged,
        super(
          reducer: reducer,
          filter: filter,
          effect: effect,
          dependencies: dependencies,
          // ignore:deprecated_member_use_from_same_package
          key: key,
        );

  @override
  Widget buildComponent(
    Store<Object> store,
    Get<Object> getter, {
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  }) {
    /// Check bus: DispatchBusDefault(); enhancer: EnhancerDefault<Object>();
    assert(bus != null && enhancer != null);

    return protectedWrapper(
      isPureView()
          ? _PureViewWidget<T>(
              store: store,
              viewBuilder: enhancer.viewEnhance(protectedView, this, store),
              getter: getter,
              bus: bus,
            )
          : ComponentWidget<T>(
              component: this,
              getter: _asGetter<T>(getter),
              store: store,
              key: key(getter()),
              bus: bus,
              enhancer: enhancer,
            ),
    );
  }

  @override
  ComponentContext<T> createContext(
    Store<Object> store,
    BuildContext buildContext,
    Get<T> getState, {
    @required void Function() markNeedsBuild,
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  }) {
    assert(bus != null && enhancer != null);
    return ComponentContext<T>(
      logic: this,
      store: store,
      buildContext: buildContext,
      getState: getState,
      view: enhancer.viewEnhance(protectedView, this, store),
      shouldUpdate: protectedShouldUpdate,
      name: name,
      markNeedsBuild: markNeedsBuild,
      sidecarCtx: adapterDep()?.createContext(
        store,
        buildContext,
        getState,
        bus: bus,
        enhancer: enhancer,
      ),
      enhancer: enhancer,
      bus: bus,
    );
  }

  ComponentState<T> createState() => ComponentState<T>();

  String get name => cache<String>('name', () => runtimeType.toString());

  bool isPureView() {
    return protectedReducer == null &&
        protectedEffect == null &&
        protectedDependencies == null;
  }

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

class _PureViewWidget<T> extends StatelessWidget {
  final ViewBuilder<T> viewBuilder;
  final Get<Object> getter;
  final DispatchBus bus;
  final Store<Object> store;

  const _PureViewWidget({
    @required this.viewBuilder,
    @required this.getter,
    @required this.bus,
    @required this.store,
  });

  @override
  Widget build(BuildContext context) => viewBuilder(
        getter(),
        (Action action) {
          store.dispatch(action);
          bus.dispatch(action);
        },
        PureViewViewService(bus, context),
      );
}

class ComponentWidget<T> extends StatefulWidget {
  final Component<T> component;
  final Store<Object> store;
  final Get<T> getter;
  final DispatchBus bus;
  final Enhancer<Object> enhancer;

  const ComponentWidget({
    @required this.component,
    @required this.store,
    @required this.getter,
    this.bus,
    this.enhancer,
    Key key,
  })  : assert(component != null),
        assert(store != null),
        assert(getter != null),
        super(key: key);

  @override
  ComponentState<T> createState() => component.createState();
}

class ComponentState<T> extends State<ComponentWidget<T>> {
  ComponentContext<T> _ctx;

  ComponentContext<T> get ctx => _ctx;

  @mustCallSuper
  @override
  Widget build(BuildContext context) => _ctx.buildWidget();

  @override
  @protected
  @mustCallSuper
  void reassemble() {
    super.reassemble();
    _ctx.clearCache();
    _ctx.onLifecycle(LifecycleCreator.reassemble());
  }

  @mustCallSuper
  @override
  void initState() {
    super.initState();

    /// init context
    _ctx = widget.component.createContext(
      widget.store,
      context,
      () => widget.getter(),
      markNeedsBuild: () {
        if (mounted) {
          setState(() {});
        }
      },
      bus: widget.bus,
      enhancer: widget.enhancer,
    );

    /// register store.subscribe
    _ctx.registerOnDisposed(widget.store.subscribe(() => _ctx.onNotify()));

    _ctx.onLifecycle(LifecycleCreator.initState());
  }

  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.component.protectedClearOnDependenciesChanged != false) {
      _ctx.clearCache();
    }

    _ctx.onLifecycle(LifecycleCreator.didChangeDependencies());
  }

  @mustCallSuper
  @override
  void deactivate() {
    super.deactivate();
    _ctx.onLifecycle(LifecycleCreator.deactivate());
  }

  @mustCallSuper
  @override
  void didUpdateWidget(ComponentWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ctx.didUpdateWidget();
    _ctx.onLifecycle(LifecycleCreator.didUpdateWidget());
  }

  @mustCallSuper
  void disposeCtx() {
    if (!_ctx.isDisposed) {
      _ctx
        ..onLifecycle(LifecycleCreator.dispose())
        ..dispose();
    }
  }

  @mustCallSuper
  @override
  void dispose() {
    disposeCtx();
    super.dispose();
  }
}
