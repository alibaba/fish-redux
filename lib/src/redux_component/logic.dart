import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../fish_redux.dart';
import '../redux/redux.dart';
import 'basic.dart';
import 'context.dart';
import 'dependencies.dart';
import 'dependent.dart';
import 'helper.dart';

/// Four parts
/// 1. Reducer & ReducerFilter
/// 2. Effect | HigherEffect & OnError   =>   OnAction
/// 3. Dependencies
/// 4. Key
class Logic<T> implements AbstractLogic<T> {
  final Reducer<T> _reducer;
  final ReducerFilter<T> filter;
  final HigherEffect<T> higherEffect;
  final OnError<T> onError;
  final Dependencies<T> dependencies;
  final Object Function(T state) _key;

  /// Used as function cache to improve operational efficiency
  final Map<String, Object> _resultCache = <String, Object>{};

  Logic({
    Reducer<T> reducer,
    this.dependencies,
    this.filter,
    Effect<T> effect,
    HigherEffect<T> higherEffect,
    this.onError,
    Object Function(T state) key,
  })  : assert(effect == null || higherEffect == null,
            'Only one style of effect could be applied.'),
        _reducer = reducer,
        higherEffect = higherEffect ?? asHigherEffect(effect),
        _key = key;

  /// if
  /// _resultCache['key'] = null;
  /// then
  /// _resultCache.containsKey('key') will be true;
  R cache<R>(String key, Get<R> getter) {
    final R result = _resultCache.containsKey(key)
        ? _resultCache[key]
        : (_resultCache[key] = getter());
    return result;
  }

  @override
  Reducer<T> get reducer => filterReducer(
      combineReducers<T>(<Reducer<T>>[_reducer, dependencies?.reducer]),
      filter);

  @override
  Object onReducer(Object state, Action action) =>
      cache<Reducer<T>>('onReducer', () => reducer)?.call(state, action) ??
      state;

  @override
  OnAction createHandlerOnAction(Context<T> ctx) {
    final OnAction onEffect = higherEffect?.call(ctx);
    return onEffect != null
        ? (Action action) {
            assert(action != null, 'Do not dispatch an action of null.');
            try {
              final Object result = onEffect(action);
              if (result is Future) {
                return result.catchError((Object e) {
                  if (!_onError(onError, e, ctx)) {
                    throw e;
                  }
                });
              } else {
                return result;
              }
            } catch (e) {
              if (!_onError(onError, e, ctx)) {
                rethrow;
              } else {
                return true;
              }
            }
          }
        : null;
  }

  @override
  OnAction createHandlerOnBroadcast(
          OnAction onAction, Context<T> ctx, Dispatch parentDispatch) =>
      onAction;

  @override
  Dispatch createDispatch(
      OnAction onAction, Context<T> ctx, Dispatch parentDispatch) {
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
  Dependent<T> slot(String type) => dependencies?.slot(type);

  @override
  Dependent<K> asDependent<K>(Connector<K, T> connector) =>
      createDependent<K, T>(connector, this);

  @override
  ContextSys<T> createContext({
    PageStore<Object> store,
    BuildContext buildContext,
    Get<T> getState,
  }) {
    return DefaultContext<T>(
      factors: this,
      store: store,
      buildContext: buildContext,
      getState: getState,
    );
  }

  @override
  Object key(T state) => _key?.call(state) ?? ValueKey<Type>(runtimeType);

  static bool _onError<T>(OnError<T> onError, Object e, Context<T> ctx) {
    return (e is SelfHealingError ? e.heal(ctx) : onError?.call(e, ctx)) ??
        false;
  }

  static Middleware<T> _applyOnAction<T>(OnAction onAction, Context<T> ctx) {
    return ({Dispatch dispatch, Get<T> getState}) {
      return (Dispatch next) {
        return (Action action) {
          final Object result = onAction?.call(action);
          if (result != null && result != false) {
            return;
          }

          //skip-lifecycle-actions
          if (action.type is Lifecycle) {
            return;
          }

          if (!shouldBeInterruptedBeforeReducer(action)) {
            ctx.pageBroadcast(action);
          }

          next(action);
        };
      };
    };
  }
}

/// if an exception is of SelfHealingError type, it will be healed automatically.
abstract class SelfHealingError {
  bool heal(Context<Object> ctx);
}

class DisposeException implements Exception, SelfHealingError {
  final String message;

  const DisposeException([this.message]);

  @override
  bool heal(Context<Object> ctx) => true;
}
