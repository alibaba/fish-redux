import '../redux/redux.dart';

enum PrivateType { ByRef, ByHash, ByKey }

class PrivateAction extends Action {
  final dynamic ref;
  PrivateAction(Object type, {dynamic payload, this.ref})
      : super(type, payload: payload);
}

Reducer<T> privateReducer<T>(Reducer<T> reducer, Object Function(T) key) {
  return (T state, Action action) {
    if (action is PrivateAction && action.ref == state) {
      return reducer(state, action);
    }
    return state;
  };
}
