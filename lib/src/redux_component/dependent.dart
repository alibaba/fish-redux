import 'package:flutter/widgets.dart' hide Action;

import '../../fish_redux.dart';
import '../redux/redux.dart';
import 'basic.dart';

class _Dependent<T, P> implements Dependent<T> {
  final AbstractConnector<T, P> connector;
  final AbstractLogic<P> logic;

  _Dependent({
    @required this.logic,
    @required this.connector,
  })  : assert(logic != null),
        assert(connector != null);

  @override
  SubReducer<T> createSubReducer() {
    final Reducer<P> reducer = logic.reducer;
    return reducer != null ? connector.subReducer(reducer) : null;
  }

  @override
  Widget buildComponent(MixedStore<Object> store, Get<T> getter) {
    assert(isComponent(), 'Unexpected type of ${logic.runtimeType}.');
    final AbstractComponent<P> component = logic;
    return component.buildComponent(store, () => connector.get(getter()));
  }

  @override
  ListAdapter buildAdapter(
      Object state, Dispatch dispatch, ViewService viewService) {
    assert(isAdapter(), 'Unexpected type of ${logic.runtimeType}.');
    final AbstractAdapter<P> adapter = logic;
    return adapter.buildAdapter(state, dispatch, viewService);
  }

  @override
  Get<P> subGetter(Get<T> getter) => () => connector.get(getter());

  @override
  ContextSys<P> createContext({
    MixedStore<Object> store,
    BuildContext buildContext,
    Get<T> getState,
  }) {
    return logic.createContext(
      store: store,
      buildContext: buildContext,
      getState: subGetter(getState),
    );
  }

  @override
  bool isComponent() => logic is AbstractComponent;

  @override
  bool isAdapter() => logic is AbstractAdapter;
}

Dependent<K> createDependent<K, T>(
        AbstractConnector<K, T> connector, Logic<T> logic) =>
    _Dependent<K, T>(connector: connector, logic: logic);
