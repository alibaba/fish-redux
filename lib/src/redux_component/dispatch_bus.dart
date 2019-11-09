import '../redux/redux.dart';
import 'basic.dart';

class DispatchBusDefault implements DispatchBus {
  final List<Dispatch> _dispatchList = <Dispatch>[];
  DispatchBus parent;
  void Function() unregister;

  DispatchBusDefault();

  @override
  void attach(DispatchBus parent) {
    this.parent = parent;
    unregister?.call();
    unregister = parent?.registerReceiver(dispatch);
  }

  @override
  void detach() {
    unregister?.call();
  }

  @override
  void dispatch(Action action, {Dispatch excluded}) {
    final List<Dispatch> list = _dispatchList
        .where((Dispatch dispatch) => dispatch != excluded)
        .toList(growable: false);

    for (Dispatch dispatch in list) {
      dispatch(action);
    }
  }

  @override
  void broadcast(Action action, {DispatchBus excluded}) {
    parent?.dispatch(action, excluded: excluded?.dispatch);
  }

  @override
  void Function() registerReceiver(Dispatch dispatch) {
    assert(!_dispatchList.contains(dispatch),
        'Do not register a dispatch which is already existed');

    if (dispatch != null) {
      _dispatchList.add(dispatch);
      return () {
        _dispatchList.remove(dispatch);
      };
    } else {
      return null;
    }
  }
}
