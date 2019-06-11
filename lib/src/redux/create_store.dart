import 'dart:async';

import 'basic.dart';

Reducer<T> _noop<T>() => (T state, Action action) => state;

typedef _VoidCallback = void Function();

void _throwIfNot(bool condition, [String message]) {
  if (!condition) {
    throw ArgumentError(message);
  }
}

Store<T> _createStore<T>(final T preloadedState, final Reducer<T> reducer) {
  _throwIfNot(
    preloadedState != null,
    'Expected the preloadedState to be non-null value.',
  );

  final List<_VoidCallback> _listeners = <_VoidCallback>[];
  final StreamController<T> _notifyController =
      StreamController<T>.broadcast(sync: true);

  T _state = preloadedState;
  Reducer<T> _reducer = reducer ?? _noop<T>();
  bool _isDispatching = false;
  bool _isDisposed = false;

  return Store<T>()
    ..getState = (() => _state)
    ..dispatch = (Action action) {
      _throwIfNot(action != null, 'Expected the action to be non-null value.');
      _throwIfNot(action.type != null,
          'Expected the action.type to be non-null value.');
      _throwIfNot(!_isDispatching, 'Reducers may not dispatch actions.');

      if (_isDisposed) {
        return;
      }

      try {
        _isDispatching = true;
        _state = _reducer(_state, action);
      } finally {
        _isDispatching = false;
      }

      final List<_VoidCallback> _notifyListeners = _listeners.toList(
        growable: false,
      );
      for (_VoidCallback listener in _notifyListeners) {
        listener();
      }

      _notifyController.add(_state);
    }
    ..replaceReducer = (Reducer<T> replaceReducer) {
      _reducer = replaceReducer ?? _noop;
    }
    ..subscribe = (_VoidCallback listener) {
      _throwIfNot(
        listener != null,
        'Expected the listener to be non-null value.',
      );
      _throwIfNot(
        !_isDispatching,
        'You may not call store.subscribe() while the reducer is executing.',
      );

      _listeners.add(listener);

      return () {
        _throwIfNot(
          !_isDispatching,
          'You may not unsubscribe from a store listener while the reducer is executing.',
        );
        _listeners.remove(listener);
      };
    }
    ..observable = (() => _notifyController.stream)
    ..teardown = () {
      _isDisposed = true;
      _listeners.clear();
      return _notifyController.close();
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
