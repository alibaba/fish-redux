import 'package:flutter/widgets.dart' hide Action;

import '../../fish_redux.dart';
import '../redux/redux.dart';
import 'basic.dart';
import 'dependencies.dart';
import 'helper.dart';

/// Four parts
/// 1. Reducer & ReducerFilter
/// 2. Effect | HigherEffect
/// 3. Dependencies
/// 4. Key
abstract class Logic<T> implements AbstractLogic<T> {
  final Reducer<T> _reducer;
  final ReducerFilter<T> _filter;
  final Effect<T> _effect;
  final HigherEffect<T> _higherEffect;
  final Dependencies<T> _dependencies;
  final Object Function(T state) _key;

  /// for extends
  Reducer<T> get protectedReducer => _reducer;
  ReducerFilter<T> get protectedFilter => _filter;
  Effect<T> get protectedEffect => _effect;
  HigherEffect<T> get protectedHigherEffect => _higherEffect;
  Dependencies<T> get protectedDependencies => _dependencies;
  Object Function(T state) get protectedKey => _key;

  /// Used as function cache to improve operational efficiency
  final Map<String, Object> _resultCache = <String, Object>{};

  Logic({
    Reducer<T> reducer,
    Dependencies<T> dependencies,
    ReducerFilter<T> filter,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    Object Function(T state) key,
  })  : assert(effect == null || higherEffect == null,
            'Only one style of effect could be applied.'),
        _reducer = reducer,
        _filter = filter,
        _effect = effect,
        _higherEffect = higherEffect,
        _dependencies = dependencies,
        _key = key;

  /// if
  /// _resultCache['key'] = null;
  /// then
  /// _resultCache.containsKey('key') will be true;
  R cache<R>(String key, Get<R> getter) => _resultCache.containsKey(key)
      ? _resultCache[key]
      : (_resultCache[key] = getter());

  @override
  Reducer<T> get reducer => filterReducer(
      combineReducers<T>(
          <Reducer<T>>[protectedReducer, protectedDependencies?.reducer]),
      protectedFilter);

  @override
  Object onReducer(Object state, Action action) =>
      cache<Reducer<T>>('onReducer', () => reducer)?.call(state, action) ??
      state;

  @override
  Dispatch createOnEffect(ContextSys<T> ctx, Enhancer<Object> enhancer) {
    final Dispatch onEffect = enhancer
        .effectEnhance(
          protectedHigherEffect ?? asHigherEffect<T>(protectedEffect),
          this,
          ctx.store,
        )
        ?.call(ctx);
    return (Action action) {
      final Object result = onEffect?.call(action);
      if (result != null && result != false) {
        return result;
      }

      //skip-lifecycle-actions
      if (action.type is Lifecycle) {
        return true;
      }
    };
  }

  @override
  Dispatch createAfterEffect(ContextSys<T> ctx, Enhancer<Object> enhancer) =>
      (Action action) {
        ctx.broadcastEffect(action);
        ctx.store.dispatch(action);
      };

  @override
  Dispatch createDispatch(Dispatch onEffect, Dispatch next, {Context<T> ctx}) =>
      (Action action) {
        final Object result = onEffect?.call(action);
        if (result != null && result != false) {
          return result;
        }

        next(action);
        return null;
      };

  @override
  Object key(T state) => _key?.call(state) ?? ValueKey<Type>(runtimeType);

  @override
  Dependent<T> slot(String type) => protectedDependencies?.slot(type);

  @override
  Dependent<T> adapterDep() => protectedDependencies?.list;
}
