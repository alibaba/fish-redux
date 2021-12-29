import 'package:flutter/material.dart' hide Action;

import '../../fish_redux.dart';
import '../redux/log.dart';
import '../redux/redux.dart';
import 'context.dart';
import 'dependencies.dart';
import 'lifecycle.dart';

abstract class BasicComponent<T> {
  BasicComponent({
    this.effect,
    this.reducer,
    this.dependencies,
    @required this.view,
    this.shouldUpdate,
  });

  final Dependencies<T> dependencies;
  final Reducer<T> reducer;
  final Effect<T> effect;
  final ViewBuilder<T> view;
  final ShouldUpdate<T> shouldUpdate;

  Reducer<T> createReducer() {
    return combineReducers<T>(
            <Reducer<T>>[reducer, dependencies?.createReducer()]) ??
        (T state, Action action) {
          return state;
        };
  }

  ComponentContext<T> createContext(
    Store<Object> store,
    Get<T> getter, {
    DispatchBus bus,
    Function() markNeedsBuild,
    BuildContext buildContext,
  }) {
    return ComponentContextImp<T>(
      store: store,
      bus: bus,
      getState: getter,
      markNeedsBuild: markNeedsBuild,
      dependencies: dependencies,
      view: view,
      effect: effect,
      buildContext: buildContext,
      shouldUpdate: shouldUpdate,
    );
  }

  Widget buildComponent(
    Store<Object> store,
    Get<T> getter, {
    @required DispatchBus dispatchBus,
  });

  List<Widget> buildComponents(
    Store<Object> store,
    Get<T> getter, {
    @required DispatchBus dispatchBus,
  });
}

class ComponentWidget<T> extends StatefulWidget {
  final BasicComponent<T> component;
  final Store<Object> store;
  final Get<T> getter;
  final DispatchBus bus;
  final Dependencies<T> dependencies;

  const ComponentWidget({
    @required this.component,
    @required this.store,
    @required this.getter,
    this.dependencies,
    this.bus,
    Key key,
  })  : assert(component != null),
        assert(store != null),
        assert(getter != null),
        super(key: key);

  @override
  _ComponentState<T> createState() => _ComponentState<T>();
}

class _ComponentState<T> extends State<ComponentWidget<T>> {
  ComponentContext<T> _ctx;
  BasicComponent<T> get component => widget.component;
  Function() subscribe;

  @override
  void initState() {
    super.initState();
    _ctx = component.createContext(
      widget.store,
      widget.getter,
      bus: widget.bus,
      buildContext: context,
      markNeedsBuild: () {
        if (mounted) {
          setState(() {});
        }
        Log.doPrint('${component.runtimeType} do relaod');
      },
    );
    _ctx.onLifecycle(LifecycleCreator.initState());
    subscribe = _ctx.store.subscribe(_ctx.onNotify);
  }

  @override
  Widget build(BuildContext context) => _ctx.buildView();

  @mustCallSuper
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ctx.onLifecycle(LifecycleCreator.didChangeDependencies());
  }

  @mustCallSuper
  @override
  void deactivate() {
    super.deactivate();
    _ctx.onLifecycle(LifecycleCreator.deactivate());
  }

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
  void didUpdateWidget(ComponentWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ctx.didUpdateWidget();
    _ctx.onLifecycle(LifecycleCreator.didUpdateWidget());
  }

  @mustCallSuper
  void disposeCtx() {
    _ctx
      ..onLifecycle(LifecycleCreator.dispose())
      ..dispose();
  }

  @mustCallSuper
  @override
  void dispose() {
    disposeCtx();
    subscribe();
    super.dispose();
  }
}

/// Component's view part
/// 1.State is used to decide how to render
/// 2.Dispatch is used to send actions
/// 3.ViewService is used to build sub-components or adapter.
typedef ViewBuilder<T> = Widget Function(
  T state,
  Dispatch dispatch,
  ComponentContext<T> context,
);

class ComponentContextImp<T> extends ComponentContext<T> {
  ComponentContextImp({
    Dependencies<T> dependencies,
    ViewBuilder<T> view,
    DispatchBus bus,
    Store<Object> store,
    Get<T> getState,
    Function() markNeedsBuild,
    Effect<T> effect,
    BuildContext buildContext,
    ShouldUpdate<T> shouldUpdate,
  }) : super(
          dependencies: dependencies,
          view: view,
          bus: bus,
          store: store,
          getState: getState,
          effect: effect,
          markNeedsBuild: markNeedsBuild,
          buildContext: buildContext,
          shouldUpdate: shouldUpdate
        );

  @override
  String toString() {
    return 'ComponentContext $T';
  }
}
