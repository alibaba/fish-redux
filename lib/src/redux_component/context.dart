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
  final Get<T> getState;

  BuildContext _buildContext;
  Dispatch _dispatch;
  OnAction _onBroadcast;

  DefaultContext({
    @required this.factors,
    @required this.store,
    @required BuildContext buildContext,
    @required this.getState,
  })  : assert(factors != null),
        assert(store != null),
        assert(buildContext != null),
        assert(getState != null),
        _buildContext = buildContext {
    final OnAction onAction = factors.createHandlerOnAction(this);

    /// create Dispatch
    _dispatch = factors.createDispatch(onAction, this, store.dispatch);

    /// Register inter-component broadcast
    _onBroadcast =
        factors.createHandlerOnBroadcast(onAction, this, store.dispatch);
    registerOnDisposed(store.registerReceiver(_onBroadcast));
  }

  @override
  BuildContext get context {
    assert(_throwIfDisposed());
    return _buildContext;
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
  void pageBroadcast(Action action, {bool excluedSelf}) {
    assert(_throwIfDisposed());
    store.sendBroadcast(
      action,
      excluded: excluedSelf == true ? _onBroadcast : null,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _buildContext = null;
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
  void pageBroadcast(Action action, {bool excluedSelf}) =>
      mainCtx.pageBroadcast(action, excluedSelf: excluedSelf);

  @override
  State<StatefulWidget> get stfState => mainCtx.stfState;
}

ContextSys<T> mergeContext<T>(ContextSys<T> mainCtx, ContextSys<T> sidecarCtx) {
  return sidecarCtx != null ? _TwinceContext<T>(mainCtx, sidecarCtx) : mainCtx;
}
