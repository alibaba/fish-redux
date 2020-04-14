import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/redux.dart';

/// batch notify to subscribers.
mixin _BatchNotify<T> on Store<T> {
  final List<void Function()> _listeners = <void Function()>[];
  bool _isBatching = false;
  bool _isSetupBatch = false;
  T _prevState;

  void setupBatch() {
    if (!_isSetupBatch) {
      _isSetupBatch = true;
      super.subscribe(_batch);

      subscribe = (void Function() callback) {
        assert(callback != null);
        _listeners.add(callback);
        return () {
          _listeners.remove(callback);
        };
      };
    }
  }

  bool isInSuitablePhase() {
    return SchedulerBinding.instance != null &&
        SchedulerBinding.instance.schedulerPhase !=
            SchedulerPhase.persistentCallbacks &&
        !(SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle &&
            WidgetsBinding.instance.renderViewElement == null);
  }

  void _batch() {
    if (!isInSuitablePhase()) {
      if (!_isBatching) {
        _isBatching = true;
        SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
          if (_isBatching) {
            _batch();
          }
        });
      }
    } else {
      final T curState = getState();
      if (!identical(_prevState, curState)) {
        _prevState = curState;

        final List<void Function()> notifyListeners = _listeners.toList(
          growable: false,
        );
        for (void Function() listener in notifyListeners) {
          listener();
        }

        _isBatching = false;
      }
    }
  }
}

class _BatchStore<T> extends Store<T> with _BatchNotify<T> {
  _BatchStore(Store<T> store) : assert(store != null) {
    getState = store.getState;
    subscribe = store.subscribe;
    replaceReducer = store.replaceReducer;
    dispatch = store.dispatch;
    observable = store.observable;
    teardown = store.teardown;

    setupBatch();
  }
}

Store<T> createBatchStore<T>(
  T preloadedState,
  Reducer<T> reducer, {
  StoreEnhancer<T> storeEnhancer,
}) =>
    _BatchStore<T>(
      createStore(
        preloadedState,
        _appendUpdateStateReducer<T>(reducer),
        storeEnhancer,
      ),
    );

/// connect with app-store

enum _UpdateState { Assign }

// replace current state
Reducer<T> _appendUpdateStateReducer<T>(Reducer<T> reducer) =>
    (T state, Action action) => action.type == _UpdateState.Assign
        ? action.payload
        : reducer == null ? state : reducer(state, action);

Store<T> connectStores<T, K>(
  Store<T> mainStore,
  Store<K> extraStore,
  T Function(T, K) update,
) {
  final void Function() subscriber = () {
    final T prevT = mainStore.getState();
    final T nextT = update(prevT, extraStore.getState());
    if (nextT != null && !identical(prevT, nextT)) {
      mainStore.dispatch(Action(_UpdateState.Assign, payload: nextT));
    }
  };

  final void Function() unsubscribe = extraStore.subscribe(subscriber);

  /// should triggle once
  subscriber();

  final Future<dynamic> Function() superMainTD = mainStore.teardown;
  mainStore.teardown = () {
    unsubscribe?.call();
    return superMainTD();
  };

  return mainStore;
}
