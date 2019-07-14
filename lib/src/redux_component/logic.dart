import 'package:flutter/widgets.dart' hide Action;

import '../redux/redux.dart';
import '../utils/utils.dart';
import 'basic.dart';
import 'dependencies.dart';
import 'helper.dart';
import 'lifecycle.dart';

/// Four parts
/// 1. Reducer & ReducerFilter
/// 2. Effect
/// 3. Dependencies
/// 4. Key
abstract class Logic<T> implements AbstractLogic<T> {
  final Reducer<T> _reducer;
  final ReducerFilter<T> _filter;
  final Effect<T> _effect;
  final Dependencies<T> _dependencies;
  final Object Function(T state) _key;

  /// for extends
  Reducer<T> get protectedReducer => _reducer;
  ReducerFilter<T> get protectedFilter => _filter;
  Effect<T> get protectedEffect => _effect;
  Dependencies<T> get protectedDependencies => _dependencies;
  Object Function(T state) get protectedKey => _key;

  /// Used as function cache to improve operational efficiency
  final Map<String, Object> _resultCache = <String, Object>{};

  Logic({
    Reducer<T> reducer,
    Dependencies<T> dependencies,
    ReducerFilter<T> filter,
    Effect<T> effect,
    Object Function(T state) key,
  })  : _reducer = reducer,
        _filter = filter,
        _effect = effect,
        _dependencies = dependencies,
        _key = key;

  @override
  Type get propertyType => T;

  bool isSuperTypeof<K>() => Tuple0<K>() is Tuple0<T>;

  bool isTypeof<K>() => Tuple0<T>() is Tuple0<K>;

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
    final Effect<T> effect = enhancer.effectEnhance(
      protectedEffect,
      this,
      ctx.store,
    );

    final Dispatch effectDispatch =
        effect != null ? (Action action) => effect(action, ctx) : null;

    return (Action action) {
      final Object result = effectDispatch?.call(action);
      if (result != null && result != false) {
        return result;
      }

      //skip-lifecycle-actions
      if (action.type is Lifecycle) {
        return true;
      }

      return null;
    };
  }

  @override
  Dispatch createAfterEffect(ContextSys<T> ctx, Enhancer<Object> enhancer) =>
      (Action action) {
        ctx.broadcastEffect(action);
        ctx.store.dispatch(action);
      };

  @override
  Dispatch createDispatch(Dispatch onEffect, Dispatch next, Context<T> ctx) =>
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
  Dependent<T> adapterDep() => protectedDependencies?.adapter;
}
