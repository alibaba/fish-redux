import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../redux/redux.dart';
import '../redux_component/basic.dart';
import 'dispatch_bus.dart';

/// inter-component broadcast
mixin _InterComponent<T> on MixedStore<T> {
  final DispatchBus _bus = DispatchBus();

  @override
  void pageBroadcast(Action action, {Dispatch excluded}) =>
      _bus.broadcast(action, excluded: excluded);

  @override
  void Function() registerComponentReceiver(Dispatch dispatch) =>
      _bus.registerReceiver(dispatch);
}

/// inter-component broadcast
mixin _InterStore<T> on MixedStore<T> {
  DispatchBus _delegate;

  void setupDispatchBus(DispatchBus delegate) => _delegate = delegate;

  @override
  void broadcast(Action action, {Dispatch excluded}) =>
      _delegate?.broadcast(action, excluded: excluded);

  @override
  void Function() registerStoreReceiver(Dispatch onAction) =>
      _delegate?.registerReceiver(dispatch);
}

/// build-component from store
mixin _SlotBuilder<T> on MixedStore<T> {
  @override
  Widget buildComponent(String name) =>
      slots == null ? null : slots[name]?.buildComponent(this, getState);

  Map<String, Dependent<T>> get slots;
}

/// batch notify to subscribers.
mixin _BatchNotify<T> on Store<T> {
  final List<void Function()> _listeners = <void Function()>[];
  bool isBatching = false;
  bool isSetupBatch = false;

  void setupBatch() {
    if (isSetupBatch) {
      isSetupBatch = true;
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

  void _batch() {
    if (SchedulerBinding.instance?.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      if (!isBatching) {
        isBatching = true;
        SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
          if (isBatching) {
            _batch();
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
    with _InterComponent<T>, _InterStore<T>, _SlotBuilder<T>, _BatchNotify<T> {
  @override
  final Map<String, Dependent<T>> slots;

  _MixedStore(Store<T> store, {this.slots, DispatchBus bus})
      : assert(store != null) {
    getState = store.getState;
    subscribe = store.subscribe;
    replaceReducer = store.replaceReducer;
    dispatch = store.dispatch;
    observable = store.observable;
    teardown = store.teardown;

    setupBatch();
    setupDispatchBus(bus);
  }
}

MixedStore<T> createMixedStore<T>(
  T preloadedState,
  Reducer<T> reducer, {
  StoreEnhancer<T> enhancer,
  Map<String, Dependent<T>> slots,
  DispatchBus bus,
}) =>
    _MixedStore<T>(
      createStore(preloadedState, reducer, enhancer),
      slots: slots,
      bus: bus,
    );
