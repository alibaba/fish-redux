import 'package:flutter/widgets.dart' hide Action;

import '../redux/redux.dart';
import '../utils/utils.dart';
import 'auto_dispose.dart';
import 'basic.dart';

/// The OOP style for parts of component is deprecated!
/// A OOP style of coding the View-Part, Adapter-Part and Effect-Part.
/// It's just the expansion of the context.

class _BasePart<T> {
  final Tuple3<T, Dispatch, ViewService> _tuple =
      Tuple3<T, Dispatch, ViewService>();

  T get state => _tuple.i0;
  Dispatch get dispatch => _tuple.i1;
  BuildContext get context => _tuple.i2.context;
  ViewService get viewService => _tuple.i2;

  bool _bind(T state, Dispatch dispatch, ViewService viewService) {
    _tuple.i0 = state;
    _tuple.i1 = dispatch;
    _tuple.i2 = viewService;
    return true;
  }

  VoidCallback bindAction(Action action) {
    final Dispatch current = dispatch;
    return () => current(action);
  }
}

@deprecated
@immutable
abstract class ViewPart<T> extends _BasePart<T> {
  Widget build();

  ViewBuilder<T> asView() {
    return (T state, Dispatch dispatch, ViewService viewService) {
      _bind(state, dispatch, viewService);
      return build();
    };
  }
}

@deprecated
@immutable
abstract class AdapterPart<T> extends _BasePart<T> {
  ListAdapter buildAdapter();

  AdapterBuilder<T> asAdapter() {
    return (T state, Dispatch dispatch, ViewService viewService) {
      _bind(state, dispatch, viewService);
      return buildAdapter();
    };
  }
}

@deprecated
abstract class EffectPart<T> extends AutoDispose {
  final Tuple2<Context<T>, Map<Object, Dispatch>> _tuple =
      Tuple2<Context<T>, Map<Object, Dispatch>>();

  Map<Object, Dispatch> createMap();

  T get state => _tuple.i0.state;
  BuildContext get context => _tuple.i0.context;
  Dispatch get dispatch => _tuple.i0.dispatch;

  Object onAction(Action action) {
    final Dispatch onSubAction = _tuple.i1[action.type];
    if (onSubAction != null) {
      return onSubAction(action) ?? true;
    }
    return null;
  }

  bool _bind(Context<T> ctx) {
    assert(_tuple.i1 == null);
    _tuple.i0 = ctx;
    setParent(ctx);
    _tuple.i1 = createMap();
    return true;
  }
}

@deprecated
HigherEffect<T> higherEffect<T>(EffectPart<T> Function() builder) {
  return (Context<T> ctx) {
    final EffectPart<T> instance = builder();
    instance._bind(ctx);
    return instance.onAction;
  };
}
