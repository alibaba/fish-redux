import 'package:flutter/material.dart';

import '../redux/redux.dart';
import 'redux_component.dart';

abstract class Dependent<T> {
  bool isComponent();

  bool isAdapter();

  Widget buildComponent(
    Store<Object> store,
    Get<T> getter, {
    @required DispatchBus bus,
  });

  List<Widget> buildComponents(
    Store<Object> store,
    Get<T> getter, {
    @required DispatchBus bus,
  });

  SubReducer<T> createSubReducer();
  
  BasicComponent<Object> get component;
}

/// A little different with Dispatch (with if it is interrupted).
/// bool for sync-functions, interrupted if true
/// Future<void> for async-functions, should always be interrupted.
// typedef OnAction = Dispatch;

/// Predicate if a component should be updated when the store is changed.
typedef ShouldUpdate<T> = bool Function(T old, T now);
