import '../redux/redux.dart';

class DispatchBus {
  final List<Dispatch> _dispatchList = <Dispatch>[];

  void broadcast(Action action, {Dispatch excluded}) {
    final List<Dispatch> list = _dispatchList
        .where((Dispatch dispatch) => dispatch != excluded)
        .toList(growable: false);

    for (Dispatch dispatch in list) {
      dispatch(action);
    }
  }

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
