import 'package:flutter/widgets.dart';

import '../../fish_redux.dart';
import '../redux/redux.dart';
import 'basic.dart';
import 'provider.dart';

class _ExtraMixin {
  Map<String, Object> _extra;
  Map<String, Object> get extra => _extra ??= <String, Object>{};
}

/// Default Context
class DefaultContext<T> extends ContextSys<T> with _ExtraMixin {
  final AbstractLogic<T> factors;
  final PageStore<Object> store;
  final Get<BuildContext> getBuildContext;
  final Get<T> getState;

  Dispatch _dispatch;

  DefaultContext({
    @required this.factors,
    @required this.store,
    @required this.getBuildContext,
    @required this.getState,
  })  : assert(factors != null),
        assert(store != null),
        assert(getBuildContext != null),
        assert(getState != null) {
    final OnAction onAction = factors.createHandlerOnAction(this);

    /// create Dispatch
    _dispatch = factors.createDispatch(onAction, this, store.dispatch);

    /// Register inter-component broadcast
    final OnAction onBroadcast =
        factors.createHandlerOnBroadcast(onAction, this, store.dispatch);
    regiestOnDisposed(store.registerReceiver(onBroadcast));
  }

  @override
  BuildContext get context {
    assert(_throwIfDisposed());
    return getBuildContext();
  }

  @override
  T get state => getState();

  @override
  Dispatch get dispatch => _dispatch;

  @override
  Widget buildComponent(String name) {
    assert(name != null, 'The name must be NotNull for buildComponent.');
    assert(_throwIfDisposed());
    final Dependent<T> dependent = factors.slot(name);
    assert(dependent != null, 'Could not found component by name "$name."');
    return dependent?.buildComponent(store, getState) ?? Container();
  }

  @override
  ListAdapter buildAdapter() {
    assert(factors is AbstractAdapter<T>);
    assert(_throwIfDisposed());
    ListAdapter result;
    if (factors is AbstractAdapter<T>) {
      final AbstractAdapter<T> abstractAdapter = factors;
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
  void appBroadcast(Action action) {
    assert(_throwIfDisposed());
    AppProvider.appBroadcast(context, action);
  }

  @override
  void pageBroadcast(Action action) {
    assert(_throwIfDisposed());
    store.sendBroadcast(action);
  }

  bool _throwIfDisposed() {
    if (isDisposed) {
      throw const DisposeException(
          'Ctx has been disposed which could not been used any more.');
    }
    return true;
  }
}

class _TwinceContext<T> extends ContextSys<T> with _ExtraMixin {
  final ContextSys<T> mainCtx;
  final ContextSys<T> sidecarCtx;

  _TwinceContext(this.mainCtx, this.sidecarCtx)
      : assert(mainCtx != null && sidecarCtx != null) {
    mainCtx.setParent(this);
    sidecarCtx.setParent(this);
  }

  @override
  void appBroadcast(Action action) => AppProvider.appBroadcast(context, action);

  @override
  ListAdapter buildAdapter() => sidecarCtx.buildAdapter();

  @override
  Widget buildComponent(String name) => mainCtx.buildComponent(name);

  @override
  BuildContext get context => mainCtx.context;

  @override
  Dispatch get dispatch => mainCtx.dispatch;

  @override
  void onLifecycle(Action action) {
    mainCtx.onLifecycle(action);
    sidecarCtx.onLifecycle(action);
  }

  @override
  T get state => mainCtx.state;

  @override
  void pageBroadcast(Action action) => mainCtx.pageBroadcast(action);
}

ContextSys<T> mergeContext<T>(ContextSys<T> mainCtx, ContextSys<T> sidecarCtx) {
  return sidecarCtx != null ? _TwinceContext<T>(mainCtx, sidecarCtx) : mainCtx;
}
