import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../redux/redux.dart';
import '../redux_component/basic.dart';

/// inter-component broadcast
mixin _Broadcast<T> on MixedStore<T> {
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

/// build-component from store
mixin _SlotBuilder<T> on MixedStore<T> {
  Widget buildComponent(String name) =>
      slots == null ? null : slots[name]?.buildComponent(this, getState);

  Map<String, Dependent<T>> get slots;
}

///
mixin _BatchNotify<T> on Store<T> {
  final List<void Function()> _listeners = <void Function()>[];
  bool isBatching = false;
  bool isSetupBatch = false;

  void setupBatch() {
    if (isSetupBatch) {
      isSetupBatch = true;
      super.subscribe(_batchedNotify);

      subscribe = (void Function() callback) {
        assert(callback != null);
        _listeners.add(callback);
        return () {
          _listeners.remove(callback);
        };
      };
    }
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

class _MixedStore<T> extends MixedStore<T>
    with _Broadcast<T>, _SlotBuilder<T>, _BatchNotify<T> {
  @override
  final Map<String, Dependent<T>> slots;

  _MixedStore(Store<T> store, {this.slots}) : assert(store != null) {
    getState = store.getState;
    subscribe = store.subscribe;
    replaceReducer = store.replaceReducer;
    dispatch = store.dispatch;
    observable = store.observable;
    teardown = store.teardown;

    ///
    setupBatch();
  }
}

MixedStore<T> createMixedStore<T>(
  T preloadedState,
  Reducer<T> reducer, {
  StoreEnhancer<T> enhancer,
  Map<String, Dependent<T>> slots,
}) =>
    _MixedStore<T>(createStore(preloadedState, reducer, enhancer),
        slots: slots);
