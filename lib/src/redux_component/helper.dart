import 'dart:async';

import 'package:flutter/widgets.dart';

import '../redux/basic.dart';
import 'basic.dart';

AdapterBuilder<T> asAdapter<T>(ViewBuilder<T> view) {
  return (T state, Dispatch dispatch, ViewService service) {
    return ListAdapter(
      (BuildContext buildContext, int index) => view(state, dispatch, service),
      1,
    );
  };
}

Reducer<T> mergeReducers<T extends K, K>(Reducer<K> sup, [Reducer<T> sub]) {
  return (T state, Action action) {
    return sub?.call(sup(state, action), action) ?? sup(state, action);
  };
}

Effect<T> mergeEffects<T extends K, K>(Effect<K> sup, [Effect<T> sub]) {
  return (Action action, Context<T> ctx) {
    return sub?.call(action, ctx) ?? sup.call(action, ctx);
  };
}

//combine & as
Reducer<T> asReducer<T>(
        Map<Object, Reducer<T>> map) =>
    (map == null || map.isEmpty)
        ? null
        : (T state, Action action) =>
            map[action.type]?.call(state, action) ?? state;

Reducer<T> filterReducer<T>(Reducer<T> reducer, ReducerFilter<T> filter) {
  return (reducer == null || filter == null)
      ? reducer
      : (T state, Action action) {
          return filter(state, action) ? reducer(state, action) : state;
        };
}

typedef SubEffect<T> = FutureOr<void> Function(Action action, Context<T> ctx);

Effect<T> combineEffects<T>(Map<Object, SubEffect<T>> map) =>
    (map == null || map.isEmpty)
        ? null
        : (Action action, Context<T> ctx) {
            final SubEffect<T> subEffect = map[action.type];
            return subEffect?.call(action, ctx) ?? subEffect != null;
          };

OnError<T> combineOnErrors<T>(List<OnError<T>> onErrors) =>
    (Exception exception, Context<T> ctx) =>
        onErrors.any((OnError<T> onError) => onError(exception, ctx));

HigherEffect<T> asHigherEffect<T>(Effect<T> effect) => effect != null
    ? (Context<T> ctx) => (Action action) => effect(action, ctx)
    : null;
