import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Action;

abstract class SimpleComponent<T> extends Component<T> {
  SimpleComponent({
    ReducerFilter<T> filter,
    Dependencies<T> dependencies,
    ShouldUpdate<T> shouldUpdate,
    WidgetWrapper wrapper,
    @deprecated Key Function(T) key,
    bool clearOnDependenciesChanged = false,
  }) : super(
          view: null,
          reducer: null,
          effect: null,
          filter: filter,
          dependencies: dependencies,
          shouldUpdate: shouldUpdate,
          wrapper: wrapper,
          key: key,
          clearOnDependenciesChanged: clearOnDependenciesChanged,
        );

  @override
  ViewBuilder<T> get protectedView => view;

  @override
  Reducer<T> get protectedReducer => reducer;

  @override
  Effect<T> get protectedEffect => effect;

  Widget view(T state, Dispatch dispatch, ViewService viewService);

  T reducer(T state, Action action) {
    return state;
  }

  /// interrupted if not [false, null]
  dynamic effect(Action action, Context<T> ctx) {
    return true;
  }
}
