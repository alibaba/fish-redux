import 'package:flutter/widgets.dart' hide Action;

import '../../fish_redux.dart';
import '../redux/redux.dart';
import 'basic.dart';
import 'dependencies.dart';
import 'dependent.dart';
import 'helper.dart';

/// Four parts
/// 1. Reducer & ReducerFilter
/// 2. Effect | HigherEffect & OnError   =>   OnAction
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
  OnAction createHandlerOnAction(ContextSys<T> ctx) => ctx.store
      .effectEnhance(
          protectedHigherEffect ?? asHigherEffect<T>(protectedEffect), this)
      ?.call(ctx);

  @override
  OnAction createHandlerOnBroadcast(
          OnAction onAction, ContextSys<T> ctx, Dispatch parentDispatch) =>
      onAction;

  @override
  Dispatch createDispatch(
      OnAction onAction, ContextSys<T> ctx, Dispatch parentDispatch) {
    Dispatch dispatch = (Action action) {
      throw Exception(
          'Dispatching while appending your effect & onError to dispatch is not allowed.');
    };

    /// attach to store.dispatch
    dispatch = _applyOnAction<T>(onAction, ctx)(
      dispatch: (Action action) => dispatch(action),
      getState: () => ctx.state,
    )(parentDispatch);
    return dispatch;
  }

  @override
  Dependent<T> slot(String type) => protectedDependencies?.slot(type);

  @override
  Dependent<K> asDependent<K>(AbstractConnector<K, T> connector) =>
      createDependent<K, T>(connector, this);

  @override
  Object key(T state) => _key?.call(state) ?? ValueKey<Type>(runtimeType);

  static Middleware<T> _applyOnAction<T>(OnAction onAction, ContextSys<T> ctx) {
    return ({Dispatch dispatch, Get<T> getState}) {
      return (Dispatch next) {
        return (Action action) {
          final Object result = onAction?.call(action);
          if (result != null && result != false) {
            return result;
          }

          //skip-lifecycle-actions
          if (action.type is Lifecycle) {
            return null;
          }

          ctx.broadcastEffect(action);

          next(action);
          return null;
        };
      };
    };
  }
}
