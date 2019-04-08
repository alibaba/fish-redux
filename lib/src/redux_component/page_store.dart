import 'package:flutter/scheduler.dart';

import '../redux/redux.dart';
import 'basic.dart';

class _Broadcast<T> implements Broadcast {
  final List<OnAction> _onActionContainer = <OnAction>[];

  @override
  void sendBroadcast(Action action, {OnAction excluded}) {
    final List<OnAction> list = _onActionContainer
        .where((OnAction onAction) => onAction != excluded)
        .toList(growable: false);

    for (OnAction onAction in list) {
      onAction(action);
    }
  }

  @override
  void Function() registerReceiver(OnAction onAction) {
    assert(!_onActionContainer.contains(onAction),
        'Do not register a dispatch which is already existed');

    if (onAction != null) {
      _onActionContainer.add(onAction);
      return () {
        _onActionContainer.remove(onAction);
      };
    } else {
      return null;
    }
  }
}

class _PageStore<T> extends PageStore<T> with _Broadcast<T> {
  final List<void Function()> _listeners = <void Function()>[];
  bool isBatching = false;

  _PageStore(Store<T> store) : assert(store != null) {
    getState = store.getState;

    store.subscribe(_batchedNotify);
    subscribe = (void Function() callback) {
      assert(callback != null);
      _listeners.add(callback);
      return () {
        _listeners.remove(callback);
      };
    };

    replaceReducer = store.replaceReducer;
    dispatch = store.dispatch;
    observable = store.observable;
    teardown = store.teardown;
  }

  void _batchedNotify() {
    if (SchedulerBinding.instance?.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      if (!isBatching) {
        isBatching = true;
        SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
          if (isBatching) {
            _batchedNotify();
          }
        });
      }
    } else {
      final List<void Function()> notifyListeners = _listeners.toList(
        growable: false,
      );
      for (void Function() listener in notifyListeners) {
        listener();
      }
      isBatching = false;
    }
  }
}

PageStore<T> createPageStore<T>(T preloadedState, Reducer<T> reducer,
        [StoreEnhancer<T> enhancer]) =>
    _PageStore<T>(createStore(preloadedState, reducer, enhancer));
