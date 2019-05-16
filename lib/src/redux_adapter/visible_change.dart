import 'package:flutter/widgets.dart';

import '../redux/redux.dart';
import '../redux_component/context.dart';
import '../redux_component/redux_component.dart';

mixin VisibleChangeMixin<T> on AbstractAdapter<T> {
  @override
  ListAdapter buildAdapter(
      T state, Dispatch dispatch, ViewService viewService) {
    return _wrapVisibleChange<T>(
      super.buildAdapter(state, dispatch, viewService),
      viewService,
    );
  }
}

class _VisibleChangeState extends State<_VisibleChangeWidget> {
  @override
  Widget build(BuildContext context) =>
      widget.itemBuilder(context, widget.index);

  @override
  void initState() {
    super.initState();
    widget.dispatch(LifecycleCreator.appear(widget.index));
  }

  @override
  void dispose() {
    widget.dispatch(LifecycleCreator.disappear(widget.index));
    super.dispose();
  }
}

class _VisibleChangeWidget extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int index;
  final Dispatch dispatch;

  const _VisibleChangeWidget({
    Key key,
    this.itemBuilder,
    this.index,
    this.dispatch,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VisibleChangeState();
}

ListAdapter _wrapVisibleChange<T>(
  ListAdapter listAdapter,
  DefaultContext<T> ctx,
) {
  final _VisibleChangeDispatch onChange =
      (ctx.extra['\$visible'] ??= _VisibleChangeDispatch(ctx.dispatch));

  return listAdapter == null
      ? null
      : ListAdapter(
          (BuildContext buildContext, int index) => _VisibleChangeWidget(
                itemBuilder: listAdapter.itemBuilder,
                index: index,
                dispatch: onChange.onAction,
              ),
          listAdapter.itemCount,
        );
}

class _VisibleChangeDispatch extends AutoDispose {
  int _appearsCount = 0;
  final Dispatch dispatch;

  _VisibleChangeDispatch(this.dispatch);

  void onAction(Action action) {
    if (action.type == Lifecycle.appear) {
      assert(_appearsCount >= 0);
      if (_appearsCount == 0) {
        if (!isDisposed) {
          dispatch(action);
        }
      }
      _appearsCount++;
    } else if (action.type == Lifecycle.disappear) {
      _appearsCount--;
      assert(_appearsCount >= 0);
      if (_appearsCount == 0) {
        if (!isDisposed) {
          dispatch(action);
        }
      }
    }
  }
}
