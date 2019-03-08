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
  _PageStore(Store<T> store) : assert(store != null) {
    getState = store.getState;
    subscribe = store.subscribe;
    replaceReducer = store.replaceReducer;
    dispatch = store.dispatch;
    observable = store.observable;
  }
}

PageStore<T> createPageStore<T>(T preloadedState, Reducer<T> reducer,
        [StoreEnhancer<T> enhancer]) =>
    _PageStore<T>(createStore(preloadedState, reducer, enhancer));
