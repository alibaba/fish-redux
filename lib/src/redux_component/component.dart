import 'package:flutter/widgets.dart' hide Action;

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
  ComponentContext<T> createContext({
    @required MixedStore<Object> store,
    @required BuildContext buildContext,
    @required Get<T> getState,
    @required void Function() markNeedsBuild,
  }) =>
      ComponentContext<T>(
        logic: this,
        store: store,
        buildContext: buildContext,
        getState: getState,
        view: store.viewEnhance(protectedView, this),
        shouldUpdate: protectedShouldUpdate,
        name: name,
        markNeedsBuild: markNeedsBuild,
        sidecarCtx: protectedDependencies?.list?.createContext(
          store: store,
          buildContext: buildContext,
          getState: getState,
        ),
      );

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
  ComponentContext<T> mainCtx;

  @mustCallSuper
  @override
  Widget build(BuildContext context) => mainCtx.buildWidget();

  @override
  @protected
  @mustCallSuper
  void reassemble() {
    super.reassemble();
    mainCtx.reassemble();
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
        markNeedsBuild: () {
          if (mounted) {
            setState(() {});
          }
        });

    /// register store.subscribe
    mainCtx
        .registerOnDisposed(widget.store.subscribe(() => mainCtx.onNotify()));

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
    mainCtx.didUpdateWidget();
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
