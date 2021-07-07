import 'basic.dart';

/// Combine an iterable of SubReducer<T> into one Reducer<T>
/// 可空
Reducer<T>? combineSubReducers<T>(Iterable<SubReducer<T>?> subReducers) {
  final List<SubReducer<T>?>? notNullReducers = subReducers
      .where((SubReducer<T>? e) => e != null)
      .toList(growable: false);

  if (notNullReducers == null || notNullReducers.isEmpty) {
    return null;
  }

  if (notNullReducers.length == 1) {
    final SubReducer<T>? single = notNullReducers.single;
    return (T state, Action action) => single?.call(state, action, false);
  }

  return (T state, Action action) {
    T? _copy;
    bool hasChanged = false;
    for (SubReducer<T>? subReducer in notNullReducers) {
      _copy = subReducer?.call(state, action, hasChanged);
      hasChanged = hasChanged || _copy != state;
    }
    assert(_copy != null);
    return _copy;
  };
}

/// Combine an iterable of Reducer<T> into one Reducer<T>
/// 可空
Reducer<T>? combineReducers<T>(Iterable<Reducer<T>?>? reducers) {
  final List<Reducer<T>?>? notNullReducers =
      reducers?.where((Reducer<T>? r) => r != null).toList(growable: false);
  if (notNullReducers == null || notNullReducers.isEmpty) {
    return null;
  }

  if (notNullReducers.length == 1) {
    return notNullReducers.single;
  }

  return (T state, Action action) {
    T nextState = state;
    for (Reducer<T>? reducer in notNullReducers) {
      /// 这里有问题，必须要重新赋值对象
      final T? _nextState = reducer?.call(nextState, action);
      nextState = _nextState!;
    }
    assert(nextState != null);
    return nextState;
  };
}

/// Convert a super Reducer<Sup> to a sub Reducer<Sub>
/// 可空
Reducer<Sub>? castReducer<Sub extends Sup, Sup>(Reducer<Sup>? sup) {
  return sup == null
      ? null
      : (Sub state, Action action) {
          final Sub result = sup(state, action) as dynamic;
          return result;
        };
}
