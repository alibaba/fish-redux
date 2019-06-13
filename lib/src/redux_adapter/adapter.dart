import 'package:flutter/widgets.dart' hide Action;

import '../../fish_redux.dart';
import '../redux/redux.dart';
import '../redux_component/logic.dart';
import '../redux_component/redux_component.dart';

/// abstract for custom extends
@immutable
abstract class Adapter<T> extends Logic<T> implements AbstractAdapter<T> {
  final AdapterBuilder<T> _adapter;

  AdapterBuilder<T> get protectedAdapter => _adapter;

  Adapter({
    @required AdapterBuilder<T> adapter,
    Reducer<T> reducer,
    ReducerFilter<T> filter,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    Dependencies<T> dependencies,
    Object Function(T) key,
  })  : assert(adapter != null),
        assert(dependencies?.adapter == null,
            'Unexpected dependencies.adapter for Adapter.'),
        _adapter = adapter,
        super(
          reducer: reducer,
          filter: filter,
          effect: effect,
          higherEffect: higherEffect,
          dependencies: dependencies,
          key: key,
        );

  @override
  ListAdapter buildAdapter(
      T state, Dispatch dispatch, ViewService viewService) {
    final ContextSys<T> ctx = viewService;
    return ctx.store
        .adapterEnhance(protectedAdapter, this)
        .call(state, dispatch, viewService);
  }
}
