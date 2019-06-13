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
    ListAdapter result;
    if (logic is AbstractAdapter<T>) {
      final AbstractAdapter<T> abstractAdapter = logic;
      result = abstractAdapter.buildAdapter(state, dispatch, this);
    }
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

class _TwinContext<T> extends ContextSys<T> with _ExtraMixin {
  final ContextSys<T> mainCtx;
  final ContextSys<T> sidecarCtx;

  _TwinContext(this.mainCtx, this.sidecarCtx)
      : assert(mainCtx != null && sidecarCtx != null) {
    mainCtx.setParent(this);
    sidecarCtx.setParent(this);
  }

  @override
  void broadcast(Action action) => mainCtx.broadcast(action);

  @override
  ListAdapter buildAdapter() => sidecarCtx.buildAdapter();

  @override
  Widget buildComponent(String name) => mainCtx.buildComponent(name);

  @override
  BuildContext get context => mainCtx.context;

  @override
  dynamic dispatch(Action action) => mainCtx.dispatch(action);

  @override
  void onLifecycle(Action action) {
    mainCtx.onLifecycle(action);
    sidecarCtx.onLifecycle(action);
  }

  @override
  T get state => mainCtx.state;

  @override
  State<StatefulWidget> get stfState => mainCtx.stfState;

  @override
  void broadcastEffect(Action action, {bool excluded}) =>
      mainCtx.broadcastEffect(action, excluded: excluded);

  @override
  void Function() addObservable(Subscribe s) => mainCtx.addObservable(s);

  @override
  MixedStore<dynamic> get store => mainCtx.store;

  @override
  void forceUpdate() => mainCtx.forceUpdate();

  @override
  void bindForceUpdate(void Function() forceUpdate) =>
      mainCtx.bindForceUpdate(forceUpdate);
}

ContextSys<T> mergeContext<T>(
        ContextSys<T> mainCtx, ContextSys<T> sidecarCtx) =>
    sidecarCtx != null ? _TwinContext<T>(mainCtx, sidecarCtx) : mainCtx;
