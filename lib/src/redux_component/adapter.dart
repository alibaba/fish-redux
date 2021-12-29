import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action;

import '../redux/redux.dart';
import 'basic.dart';
import 'basic_component.dart';

//////////////////////////////////////////
typedef IndexedDependentBuilder<T> = Dependent<T> Function(int);

class DependentArray<T> {
  final IndexedDependentBuilder<T> builder;
  final int length;

  DependentArray({@required this.builder, @required this.length})
      : assert(builder != null && length >= 0);

  DependentArray.fromList(List<Dependent<T>> list)
      : this(builder: (int index) => list[index], length: list.length);

  Dependent<T> operator [](int index) => builder(index);
}

typedef FlowAdapterView<T> = DependentArray<T> Function(T);

class FlowDependencies<T> {
  final FlowAdapterView<T> build;

  const FlowDependencies(this.build);

  Reducer<T> createReducer() => (T state, Action action) {
        T copy = state;
        bool hasChanged = false;
        final DependentArray<T> list = build(state);
        if (list != null) {
          for (int i = 0; i < list.length; i++) {
            final Dependent<T> dep = list[i];
            final SubReducer<T> subReducer = dep?.createSubReducer();
            if (subReducer != null) {
              copy = subReducer(copy, action, hasChanged);
              hasChanged = hasChanged || copy != state;
            }
          }
        }
        return copy;
      };
}

/// [ComposedComponent]
///
class Adapter<T> extends BasicComponent<T> {
  final FlowAdapterView<T> _adapter;
  final FlowDependencies<T> _dependencies;
  ComponentContext<T> _ctx;

  Adapter({
    Reducer<T> reducer,
    @required FlowDependencies<T> dependencies,
    ShouldUpdate<T> shouldUpdate,
  })  : _adapter = dependencies.build,
        _dependencies = dependencies,
        super(
          reducer: reducer,
          view: null,
          shouldUpdate: shouldUpdate,
        );

  @override
  Reducer<T> createReducer() {
    return combineReducers<T>(<Reducer<T>>[
          super.createReducer(),
          _dependencies.createReducer()
        ]) ??
        (T state, Action action) {
          return state;
        };
  }

  @override
  Widget buildComponent(
    Store<Object> store,
    Get<T> getter, {
    DispatchBus dispatchBus,
  }) {
    throw Exception('ComposedComponent could not build single component');
  }

  DependentArray<T> _dependentArray;

  @override
  List<Widget> buildComponents(
    Store<Object> store,
    Get<T> getter, {
    DispatchBus dispatchBus,
  }) {
    _ctx ??= createContext(
      store,
      getter,
      bus: dispatchBus,
      markNeedsBuild: () {
        Log.doPrint('$runtimeType do relaod');
      },
    );
    _dependentArray = _adapter(getter());
    final List<Widget> _widgets = <Widget>[];
    for (int i = 0; i < _dependentArray.length; i++) {
      final Dependent<T> _dependent = _dependentArray.builder(i);
      _widgets.addAll(
        _dependent.buildComponents(
          store,
          getter,
          bus: dispatchBus,
        ),
      );
    }
    _ctx.onLifecycle(LifecycleCreator.initState());
    return _widgets;
  }
}
