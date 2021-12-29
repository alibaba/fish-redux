import 'package:flutter/material.dart' hide Action;

import '../../fish_redux.dart';
import '../redux/connector.dart';
import '../redux/redux.dart';
import 'basic.dart';
import 'component.dart';
import 'basic_component.dart';

SubReducer<T> _conn<T, P>(
    Reducer<Object> reducer, MutableConn<T, P> connector) {
  return reducer == null
      ? null
      : connector
          .subReducer((P state, Action action) => reducer(state, action));
}

class _Dependent<T, P> extends Dependent<T> {
  final MutableConn<T, P> connector;
  SubReducer<T> _subReducer;
  final Reducer<P> _reducer;
  final BasicComponent<P> _component;

  _Dependent({
    BasicComponent<P> component,
    @required this.connector,
  })  : _reducer = component.createReducer(),
        _component = component {
    _subReducer = _conn<T, P>(
        _reducer == null
            ? null
            : (Object state, Action action) {
                return _reducer(state, action);
              },
        connector);
  }

  @override
  bool isComponent() => _component is Component;

  @override
  bool isAdapter() => !isComponent();

  @override
  Widget buildComponent(
    Store<Object> store,
    Get<T> getter, {
    DispatchBus bus,
  }) {
    return _component.buildComponent(
      store,
      () => connector.get(getter()),
      dispatchBus: bus,
    );
  }

  @override
  SubReducer<T> createSubReducer() => _subReducer;

  @override
  List<Widget> buildComponents(
    Store<Object> store,
    Get<T> getter, {
    DispatchBus bus,
  }) {
    return _component.buildComponents(
      store,
      () => connector.get(getter()),
      dispatchBus: bus,
    );
  }

  @override
  BasicComponent<Object> get component => _component;
}

Dependent<K> createDependent<K, T>(
  MutableConn<K, T> connector,
  BasicComponent<T> component,
) =>
    component == null
        ? null
        : (_Dependent<K, T>(
            connector: connector,
            component: component,
          ));

mixin ConnOpMixin<T, P> on MutableConn<T, P> {
  Dependent<T> operator +(BasicComponent<P> component) => createDependent<T, P>(
        this,
        component,
      );
}
