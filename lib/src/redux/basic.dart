import 'dart:async';

/// This document describes the core concepts under the Redux system and their standard definitions.
/// Mainly includes:
/// 1. The concepts of ReduxJs community
///    Action          ---- Definition of intention by plain object
///    Reducer<T>      ---- How to modify the data by a pure function
///    Dispatch        ---- Expression of intention
///    Middleware<T>   ---- AOP
///    Store<T>        ---- State management center
/// 2. Additional abstractions beyond the basic concepts of the ReduxJs community.
///    Connector<S, P> ---- The connection between big object <S> and small object <P>
///    SubReducer<T>   ---- A function that modifies data of partial <T>
///    The role of this layer of abstraction
///    a. It is obvious that the implementation of combineReducers are decoupled with the grammatical features of JS
///    b. The deeper is the contradiction between the centralization of Redux and the division of components can be solved.

/// Action is a way of defining "intention".
///     1. It emphasizes the clarity of an intention, not the implementation of the intent.
///     2. Usually the implementation of the intent is done by Effect or Reducer.
///     3. type: indicates the type of intent; payload: the original information loaded with the intent.
///     4. Action definitions and standards, strictly follow the definition and standards of Action in the Redux community.
class Action {
  const Action(this.type, {this.payload});
  final Object type;
  final dynamic payload;
}

/// Definition of the standard Reducer.
/// If the Reducer needs to respond to the Action, it returns a new state, otherwise it returns the old state.
typedef Reducer<T> = T Function(T state, Action action);

/// Definition of the standard Dispatch.
/// Send an "intention".
typedef Dispatch = dynamic Function(Action action);

/// Definition of a standard subscription function.
/// input a subscriber and output an anti-subscription function.
typedef Subscribe = void Function() Function(void Function() callback);

/// ReplaceReducer 的定义
typedef ReplaceReducer<T> = void Function(Reducer<T> reducer);

/// Definition of the standard observable flow.
typedef Observable<T> = Stream<T> Function();

/// Definition of synthesizable functions.
typedef Composable<T> = T Function(T next);

/// Definition of the function type that returns type R.
typedef Get<R> = R Function();

/// Definition of the standard Middleware.
typedef Middleware<T> = Composable<Dispatch> Function({
  Dispatch dispatch,
  Get<T> getState,
});

/// Definition of the standard Store.
class Store<T> {
  Get<T> getState;
  Dispatch dispatch;
  Subscribe subscribe;
  Observable<T> observable;
  ReplaceReducer<T> replaceReducer;
  Future<dynamic> Function() teardown;
}

/// Create a store definition
typedef StoreCreator<T> = Store<T> Function(
  T preloadedState,
  Reducer<T> reducer,
);

/// Definition of Enhanced creating a store
typedef StoreEnhancer<T> = StoreCreator<T> Function(StoreCreator<T> creator);

/// Definition of SubReducer
/// [isStateCopied] is Used to optimize execution performance.
/// Ensure that a T will be cloned at most once during the entire process.
typedef SubReducer<T> = T Function(T state, Action action, bool isStateCopied);

/// Definition of Connector which connects Reducer<S> with Reducer<P>.
/// 1. How to get an instance of type P from an instance of type S.
/// 2. How to synchronize changes of an instance of type P to an instance of type S.
/// 3. How to clone a new S.
abstract class AbstractConnector<S, P> {
  P get(S state);

  /// For mutable state, there are three abilities needed to be met.
  ///     1. get: (S) => P
  ///     2. set: (S, P) => void
  ///     3. shallow copy: s.clone()
  ///
  /// For immutable state, there are two abilities needed to be met.
  ///     1. get: (S) => P
  ///     2. set: (S, P) => S
  ///
  /// See in [connector].
  SubReducer<S> subReducer(Reducer<P> reducer);
}
