import 'dart:async';

import 'basic.dart';

Reducer<T> _noop<T>() => (T state, Action action) => state;

typedef _VoidCallback = void Function();

void _throwIfNot(bool condition, [String message]) {
  if (!condition) {
    throw ArgumentError(message);
  }
}

Store<T> _createStore<T>(T preloadedState, Reducer<T> reducer) {
  _throwIfNot(preloadedState != null,
      'Expected the preloadedState to be non-null value.');

  T state = preloadedState;
  reducer = reducer ?? _noop<T>();

  bool isDispatching = false;
  final List<_VoidCallback> listeners = <_VoidCallback>[];
  final StreamController<T> notifyController =
      StreamController<T>.broadcast(sync: true);

  final Dispatch dispatch = (Action action) {
    _throwIfNot(action != null, 'Expected the action to be non-null value.');
    _throwIfNot(
        action.type != null, 'Expected the action.type to be non-null value.');
    _throwIfNot(!isDispatching, 'Reducers may not dispatch actions.');

    try {
      isDispatching = true;
      state = reducer(state, action);
    } finally {
      isDispatching = false;
    }

    final List<_VoidCallback> _notifyListeners = listeners.toList(
      growable: false,
    );
    for (_VoidCallback listener in _notifyListeners) {
      listener();
    }

    notifyController.add(state);
  };

  return Store<T>()
    ..getState = (() => state)
    ..dispatch = dispatch
    ..replaceReducer = (Reducer<T> replaceReducer) {
      reducer = replaceReducer ?? _noop;
      dispatch(const Action(ActionType.replace));
    }
    ..subscribe = (_VoidCallback listener) {
      _throwIfNot(
          listener != null, 'Expected the listener to be non-null value.');
      _throwIfNot(!isDispatching,
          'You may not call store.subscribe() while the reducer is executing.');

      listeners.add(listener);

      return () {
        _throwIfNot(!isDispatching,
            'You may not unsubscribe from a store listener while the reducer is executing.');
        listeners.remove(listener);
      };
    }
    ..observable = (() => notifyController.stream)
    ..teardown = () {
      listeners.clear();
      return notifyController.close();
    };
}

/// create a store with enhancer
Store<T> createStore<T>(T preloadedState, Reducer<T> reducer,
        [StoreEnhancer<T> enhancer]) =>
    enhancer != null
        ? enhancer(_createStore)(preloadedState, reducer)
        : _createStore(preloadedState, reducer);

StoreEnhancer<T> composeStoreEnhancer<T>(List<StoreEnhancer<T>> enhancers) =>
    enhancers == null || enhancers.isEmpty
        ? null
        : enhancers.reduce((StoreEnhancer<T> previous, StoreEnhancer<T> next) =>
            (StoreCreator<T> creator) => next(previous(creator)));
