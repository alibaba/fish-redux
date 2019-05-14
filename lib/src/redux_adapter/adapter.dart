import 'package:flutter/widgets.dart';

import '../../fish_redux.dart';
import '../redux/redux.dart';
import '../redux_component/logic.dart';
import '../redux_component/redux_component.dart';

/// abstract for custom extends
@immutable
abstract class Adapter<T> extends Logic<T> implements AbstractAdapter<T> {
  final AdapterBuilder<T> adapter;

  Adapter({
    @required this.adapter,
    Reducer<T> reducer,
    ReducerFilter<T> filter,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    Dependencies<T> dependencies,
    Object Function(T) key,
  })  : assert(adapter != null),
        assert(dependencies?.adapter == null,
            'Unexpected dependencies.adapter for Adapter.'),
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
    final ListAdapter listAdapter = adapter(state, dispatch, viewService);
    return isDebug() ? listAdapter : _beSafeInRelease(listAdapter, dispatch);
  }

  static ListAdapter _beSafeInRelease(
      ListAdapter listAdapter, Dispatch dispatch) {
    return ListAdapter(
      (BuildContext context, int index) {
        Widget result;
        try {
          result = listAdapter.itemBuilder(context, index);
        } catch (e, stackTrace) {
          /// The upper layer decides how to consume error.
          // dispatch($DebugOrReportCreator.reportBuildError(e, stackTrace));
          /// todo

          result = Container();
        }
        return result;
      },
      listAdapter.itemCount,
    );
  }
}
