import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/basic.dart';
import '../utils/utils.dart';
import 'basic.dart';
import 'lifecycle.dart';

Get<T> asGetter<T>(Get<dynamic> getter) {
  Get<T> runtimeGetter;
  if (getter is Get<T>) {
    runtimeGetter = getter;
  } else {
    runtimeGetter = () {
      final T result = getter();
      return result;
    };
  }
  return runtimeGetter;
}

AdapterBuilder<T> asAdapter<T>(ViewBuilder<T> view) {
  return (T unstableState, Dispatch dispatch, ViewService service) {
    final ContextSys<T> ctx = service as ContextSys<T>;
    return ListAdapter(
      (BuildContext buildContext, int index) => view(ctx.state, dispatch, service),
      1,
    );
  };
}

Reducer<T> mergeReducers<T extends K, K>(Reducer<K> sup, [Reducer<T>? sub]) {
  return (T state, Action action) {
    return sub?.call(sup(state, action) as T, action) ?? sup(state, action) as T;
  };
}

Effect<T> mergeEffects<T extends K, K>(Effect<K> sup, [Effect<T>? sub]) {
  return (Action action, Context<T> ctx) {
    return sub?.call(action, ctx) ?? sup.call(action, ctx);
  };
}

/// combine & as
/// for action.type which override it's == operator
Reducer<T>? asReducer<T>(Map<Object, Reducer<T>>? map) {
  return (map == null || map.isEmpty)
      ? null
      : (T state, Action action) {
          MapEntry<Object, Reducer<T>>? reducer;
          for (MapEntry<Object, Reducer<T>> element in map.entries) {
            if (action.type == element.key) {
              reducer = element;
              break;
            }
          }
          // map.entries
          //         .firstWhereOrNull((MapEntry<Object, Reducer<T>> entry) => action.type == entry.key)
          //         ?.value(state, action) ??
          //     state;

          return reducer?.value(state, action) ?? state;
        };
}

/// 可空 【helper.dart#62】
Reducer<T>? filterReducer<T>(Reducer<T>? reducer, ReducerFilter<T>? filter) {
  return (reducer == null || filter == null)
      ? reducer
      : (T state, Action action) {
          return filter(state, action) ? reducer(state, action) : state;
        };
}

const Object _SUB_EFFECT_RETURN_NULL = Object();

typedef SubEffect<T> = FutureOr<void> Function(Action action, Context<T> ctx);

/// for action.type which override it's == operator
/// return [UserEffecr]
Effect<T>? combineEffects<T>(Map<Object, SubEffect<T>> map) => (map == null || map.isEmpty)
    ? null
    : (Action action, Context<T> ctx) {
        final SubEffect<T>? subEffect = map.entries
            .firstWhereOrNull(
              (MapEntry<Object, SubEffect<T>> entry) => action.type == entry.key,
            )
            ?.value;

        if (subEffect != null) {
          return subEffect.call(action, ctx) ?? _SUB_EFFECT_RETURN_NULL;
        }

        //skip-lifecycle-actions
        if (action.type is Lifecycle) {
          return _SUB_EFFECT_RETURN_NULL;
        }

        /// no subEffect
        return null;
      };

/// return [EffectDispatch]
Dispatch createEffectDispatch<T>(Effect<T>? userEffect, Context<T> ctx) {
  return (Action action) {
    final Object? result = userEffect?.call(action, ctx);

    //skip-lifecycle-actions
    if (action.type is Lifecycle && (result == null || result == false)) {
      return _SUB_EFFECT_RETURN_NULL;
    }

    return result;
  };
}

/// return [NextDispatch]
Dispatch createNextDispatch<T>(ContextSys<T> ctx) => (Action action) {
      ctx.broadcastEffect(action, excluded: true);
      ctx.store.dispatch(action);
    };

/// return [Dispatch]
/// 可空 onEffect？
Dispatch createDispatch<T>(Dispatch? onEffect, Dispatch next, Context<T> ctx) => (Action action) {
      final Object? result = onEffect?.call(action);
      if (result == null || result == false) {
        next(action);
      }

      return result == _SUB_EFFECT_RETURN_NULL ? null : result;
    };

/// 可空 【collections.dart#7】
ViewMiddleware<T>? mergeViewMiddleware<T>(List<ViewMiddleware<T>> middleware) {
  return Collections.reduce<ViewMiddleware<T>>(middleware, (ViewMiddleware<T> first, ViewMiddleware<T> second) {
    return (AbstractComponent<dynamic> component, Store<T> store) {
      final Composable<ViewBuilder<dynamic>> inner = first(component, store);
      final Composable<ViewBuilder<dynamic>> outer = second(component, store);
      return (ViewBuilder<dynamic> view) {
        return outer(inner(view));
      };
    };
  });
}

/// 可空 【collections.dart#7】
AdapterMiddleware<T>? mergeAdapterMiddleware<T>(List<AdapterMiddleware<T>> middleware) {
  return Collections.reduce<AdapterMiddleware<T>>(middleware,
      (AdapterMiddleware<T> first, AdapterMiddleware<T> second) {
    return (AbstractAdapter<dynamic> component, Store<T> store) {
      final Composable<AdapterBuilder<dynamic>> inner = first(component, store);
      final Composable<AdapterBuilder<dynamic>> outer = second(component, store);
      return (AdapterBuilder<dynamic> view) {
        return outer(inner(view));
      };
    };
  });
}

/// 可空 【collections.dart#7】
EffectMiddleware<T>? mergeEffectMiddleware<T>(List<EffectMiddleware<T>> middleware) {
  return Collections.reduce<EffectMiddleware<T>>(middleware, (EffectMiddleware<T> first, EffectMiddleware<T> second) {
    return (AbstractLogic<dynamic> logic, Store<T> store) {
      final Composable<Effect<dynamic>> inner = first(logic, store);
      final Composable<Effect<dynamic>> outer = second(logic, store);
      return (Effect<dynamic> effect) {
        return outer(inner(effect));
      };
    };
  });
}
