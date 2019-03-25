import 'basic.dart';

/// Combine an iterable of SubReducer<T> into one Reducer<T>
Reducer<T> combineSubReducers<T>(Iterable<SubReducer<T>> subReducers) {
  final List<SubReducer<T>> notNullReducers = subReducers
      ?.where((SubReducer<T> e) => e != null)
      ?.toList(growable: false);

  if (notNullReducers == null || notNullReducers.isEmpty) {
    return null;
  }

  if (notNullReducers.length == 1) {
    final SubReducer<T> single = notNullReducers.single;
    return (T state, Action action) => single(state, action, false);
  }

  return (T state, Action action) {
    T copy = state;
    bool hasChanged = false;
    for (SubReducer<T> subReducer in notNullReducers) {
      copy = subReducer(copy, action, hasChanged);
      hasChanged = hasChanged || copy != state;
    }
    assert(copy != null);
    return copy;
  };
}

/// Combine an iterable of Reducer<T> into one Reducer<T>
Reducer<T> combineReducers<T>(Iterable<Reducer<T>> reducers) {
  final List<Reducer<T>> notNullReducers =
      reducers?.where((Reducer<T> r) => r != null)?.toList(growable: false);
  if (notNullReducers == null || notNullReducers.isEmpty) {
    return null;
  }

  if (notNullReducers.length == 1) {
    return notNullReducers.single;
  }

  return (T state, Action action) {
    T nextState = state;
    for (Reducer<T> reducer in notNullReducers) {
      nextState = reducer(nextState, action);
    }
    assert(nextState != null);
    return nextState;
  };
}

/// Convert a super Reducer<Sup> to a sub Reducer<Sub>
Reducer<Sub> castReducer<Sub extends Sup, Sup>(Reducer<Sup> sup) {
  return sup == null
      ? null
      : (Sub state, Action action) {
          final Sub result = sup(state, action);
          return result;
        };
}
