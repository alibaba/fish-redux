import 'package:flutter/widgets.dart';

import '../../fish_redux.dart';
import '../redux/redux.dart';
import 'basic.dart';

class _Dependent<T, P> implements Dependent<T> {
  final Connector<T, P> connector;
  final AbstractLogic<P> factors;

  _Dependent({
    @required this.factors,
    @required this.connector,
  })  : assert(factors != null),
        assert(connector != null);

  @override
  SubReducer<T> createSubReducer() {
    final Reducer<P> reducer = factors.reducer;
    return reducer != null ? subReducer(connector, reducer) : null;
  }

  @override
  Widget buildComponent(PageStore<Object> store, Get<T> getter) {
    assert(isComponent(), 'Unexpected type of ${factors.runtimeType}.');
    final AbstractComponent<P> component = factors;
    return component.buildComponent(store, () => connector.get(getter()));
  }

  @override
  ListAdapter buildAdapter(
      Object state, Dispatch dispatch, ViewService viewService) {
    assert(isAdapter(), 'Unexpected type of ${factors.runtimeType}.');
    final AbstractAdapter<P> adapter = factors;
    return adapter.buildAdapter(state, dispatch, viewService);
  }

  @override
  Get<P> subGetter(Get<T> getter) => () => connector.get(getter());

  @override
  ContextSys<P> createContext({
    PageStore<Object> store,
    BuildContext buildContext,
    Get<T> getState,
  }) {
    return factors.createContext(
      store: store,
      buildContext: buildContext,
      getState: subGetter(getState),
    );
  }

  @override
  bool isComponent() => factors is AbstractComponent;

  @override
  bool isAdapter() => factors is AbstractAdapter;
}

Dependent<K> createDependent<K, T>(
        Connector<K, T> connector, Logic<T> factors) =>
    _Dependent<K, T>(connector: connector, factors: factors);
