import 'package:flutter/widgets.dart' hide Action;

import '../../fish_redux.dart';
import '../redux/redux.dart';
import 'basic.dart';

mixin _ExtraMixin {
  Map<String, Object> _extra;
  Map<String, Object> get extra => _extra ??= <String, Object>{};
}

/// Default Context
class DefaultContext<T> extends ContextSys<T> with _ExtraMixin {
  final AbstractLogic<T> logic;
  @override
  final MixedStore<Object> store;
  final Get<T> getState;

  void Function() _forceUpdate;

  BuildContext _buildContext;
  Dispatch _dispatch;
  Dispatch _onBroadcast;

  DefaultContext({
    @required this.logic,
    @required this.store,
    @required BuildContext buildContext,
    @required this.getState,
  })  : assert(logic != null),
        assert(store != null),
        assert(buildContext != null),
        assert(getState != null),
        _buildContext = buildContext {
    final Dispatch onAction = logic.createHandlerOnAction(this);

    /// create Dispatch
    _dispatch = logic.createDispatch(onAction, this, store.dispatch);

    /// Register inter-component broadcast
    _onBroadcast =
        logic.createHandlerOnBroadcast(onAction, this, store.dispatch);
    registerOnDisposed(store.registerComponentReceiver(_onBroadcast));
  }

  @override
  void bindForceUpdate(void Function() forceUpdate) {
    assert(_forceUpdate == null);
    _forceUpdate = forceUpdate;
  }

  @override
  BuildContext get context => _buildContext;

  @override
  T get state => getState();

  @override
  dynamic dispatch(Action action) => _dispatch(action);

  @override
  Widget buildComponent(String name) {
    assert(name != null, 'The name must be NotNull for buildComponent.');
    final Dependent<T> dependent = logic.slot(name);
    final Widget result = dependent?.buildComponent(store, getState) ??
        store.buildComponent(name);
    assert(result != null, 'Could not found component by name "$name."');
    return result ?? Container();
  }

  @override
  ListAdapter buildAdapter() {
    assert(logic is AbstractAdapter<T>);
    final AbstractAdapter<T> abstractAdapter = logic;
    final ListAdapter result = abstractAdapter.buildAdapter(this);
    return result ?? const ListAdapter(null, 0);
  }

  @override
  void onLifecycle(Action action) {
    assert(_throwIfDisposed());
    _dispatch(action);
  }

  @override
  void broadcast(Action action) {
    store.broadcast(action);
  }

  @override
  void dispose() {
    super.dispose();
    _buildContext = null;
    _forceUpdate = null;
  }

  bool _throwIfDisposed() {
    if (isDisposed) {
      throw const DisposeException(
          'Ctx has been disposed which could not been used any more.');
    }
    return true;
  }

  @override
  State<StatefulWidget> get stfState {
    assert(_buildContext is StatefulElement);
    if (_buildContext is StatefulElement) {
      final StatefulElement stfElement = _buildContext;
      return stfElement.state;
    }
    return null;
  }

  @override
  void broadcastEffect(Action action, {bool excluded}) =>
      store.broadcastEffect(action,
          excluded: excluded == true ? _onBroadcast : null);

  @override
  void Function() addObservable(Subscribe observable) {
    final void Function() unsubscribe = observable(() {
      _forceUpdate?.call();
    });
    registerOnDisposed(unsubscribe);
    return unsubscribe;
  }

  @override
  void forceUpdate() => _forceUpdate?.call();
}

class ComponentContext<T> extends DefaultContext<T> implements ViewUpdater<T> {
  final ViewBuilder<T> view;
  final ShouldUpdate<T> shouldUpdate;
  final String name;
  final Function() markNeedsBuild;
  final ContextSys<Object> sidecarCtx;

  Widget _widgetCache;
  T _latestState;

  ComponentContext({
    @required AbstractComponent<T> logic,
    @required MixedStore<Object> store,
    @required BuildContext buildContext,
    @required Get<T> getState,
    @required this.view,
    @required this.shouldUpdate,
    @required this.name,
    @required this.markNeedsBuild,
    @required this.sidecarCtx,
  }) : super(
          logic: logic,
          store: store,
          buildContext: buildContext,
          getState: getState,
        ) {
    _latestState = state;

    sidecarCtx?.setParent(this);
  }

  @override
  void onLifecycle(Action action) {
    super.onLifecycle(action);
    sidecarCtx?.onLifecycle(LifecycleCreator.reassemble());
  }

  @override
  ListAdapter buildAdapter() {
    assert(sidecarCtx != null);
    return sidecarCtx?.buildAdapter() ?? const ListAdapter(null, 0);
  }

  @override
  Widget buildWidget() {
    Widget result = _widgetCache;
    if (result == null) {
      result = _widgetCache = view(state, dispatch, this);

      dispatch(LifecycleCreator.build(name));
    }
    return result;
  }

  @override
  void didUpdateWidget() {
    final T now = state;
    if (shouldUpdate(_latestState, now)) {
      _widgetCache = null;
      _latestState = now;
    }
  }

  @override
  void onNotify() {
    final T now = state;
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
