import 'dart:async';

import 'basic.dart';

Reducer<T> _noop<T>() => (T state, Action action) => state;

typedef _VoidCallback = void Function();

Store<T> _createBasicStore<T>(T preloadedState, Reducer<T> reducer) {
  if (preloadedState == null) {
    throw ArgumentError('Please provide a preloadedState.');
  }

  T state = preloadedState;
  reducer = reducer ?? _noop<T>();

  bool isDispatching = false;
  final List<_VoidCallback> listeners = <_VoidCallback>[];
  final StreamController<T> notifyController =
      StreamController<T>.broadcast(sync: true);

  final Dispatch dispatch = (Action action) {
    assert(action != null && action.type != null, 'Invalide action.');
    assert(!isDispatching, 'Reducer is executing!');

    if (action.type == ActionType.destroy) {
      notifyController.close();
      listeners.clear();
      return;
    }

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
      assert(listener != null, 'Invalide listener!');
      assert(!isDispatching, 'Reducer is executing!');

      listeners.add(listener);

      return () {
        assert(!isDispatching, 'Reducer is executing!');
        listeners.remove(listener);
      };
    }
    ..observable = (() => notifyController.stream);
}

/// create a store with enhancer
Store<T> createStore<T>(T preloadedState, Reducer<T> reducer,
        [StoreEnhancer<T> enhancer]) =>
    enhancer != null
        ? enhancer(_createBasicStore)(preloadedState, reducer)
        : _createBasicStore(preloadedState, reducer);

StoreEnhancer<T> composeStoreEnhancer<T>(List<StoreEnhancer<T>> enhancers) {
  if (enhancers?.isNotEmpty == true) {
    return null;
  }
  return enhancers.reduce((StoreEnhancer<T> previous, StoreEnhancer<T> next) =>
      (StoreCreator<T> creator) => next(previous(creator)));
}
