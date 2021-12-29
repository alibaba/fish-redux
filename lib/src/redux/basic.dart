import 'dart:async';

import 'package:fish_redux/fish_redux.dart';

/// Definition of the function type that returns type R.
typedef Get<R> = R Function();

/// [Effect]是对副作用函数的定义.
/// 根据返回值, 判断该Action事件是否被消费.
typedef Effect<T> = FutureOr<void> Function(Action action, ComponentContext<T> ctx);

typedef SubEffect<T> = FutureOr<void> Function(Action action, ComponentContext<T> ctx);

const Object _SUB_EFFECT_RETURN_NULL = Object();

/// for action.type which override it's == operator
/// return [UserEffecr]
Effect<T> combineEffects<T>(Map<Object, SubEffect<T>> map) =>
    (map == null || map.isEmpty)
        ? null
        : (Action action, ComponentContext<T> ctx) {
            final SubEffect<T> subEffect = map.entries
                .firstWhere(
                  (MapEntry<Object, SubEffect<T>> entry) =>
                      action.type == entry.key,
                  orElse: () => null,
                )
                ?.value;

            if (subEffect != null) {
              return (subEffect.call(action, ctx) ?? _SUB_EFFECT_RETURN_NULL) == null;
            }
            /// no subEffect
            return null;
          };


/// [Reducer]是对状态变化函数的定义
/// 如果对状态有修改, 需要返回一个包含修改的新的对象.
typedef Reducer<T> = T Function(T, Action);

/// combine & as
/// for action.type which override it's == operator
Reducer<T> asReducer<T>(Map<Object, Reducer<T>> map) => (map == null ||
        map.isEmpty)
    ? null
    : (T state, Action action) =>
        map.entries
            .firstWhere(
                (MapEntry<Object, Reducer<T>> entry) =>
                    action.type == entry.key,
                orElse: () => null)
            ?.value(state, action) ??
        state;

typedef SubReducer<T> = T Function(T state, Action action, bool isStateCopied);

/// dispatch about
/// [DispatchBus] global eventBus 
abstract class DispatchBus {
  void attach(DispatchBus parent);

  void detach();

  void dispatch(Action action, {Dispatch excluded});

  void broadcast(Action action, {DispatchBus excluded});

  void Function() registerReceiver(Dispatch dispatch);
}

/// [Dispatch] patch action function
typedef Dispatch = dynamic Function(Action action);

/// [Action] [Effect] message action
class Action {
  const Action(this.type, {this.payload});
  final Object type;
  final dynamic payload;
}

/// [Store]
/// 

/// Definition of a standard subscription function.
/// input a subscriber and output an anti-subscription function.
typedef Subscribe = void Function() Function(void Function() callback);

/// Definition of the standard observable flow.
typedef Observable<T> = Stream<T> Function();

/// ReplaceReducer 的定义
typedef ReplaceReducer<T> = void Function(Reducer<T> reducer);

/// Definition of the standard Store.
class Store<T> {
  Get<T> getState;
  Dispatch dispatch;
  Subscribe subscribe;
  Observable<T> observable;
  ReplaceReducer<T> replaceReducer;
  Future<dynamic> Function() teardown;
}

/// Definition of synthesizable functions.
typedef Composable<T> = T Function(T next);

/// Definition of the standard Middleware.
typedef Middleware<T> = Composable<Dispatch> Function({
  Dispatch dispatch,
  Get<T> getState,
});